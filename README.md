**Não deixe a arquitetura depender da memória das pessoas — automatize com fitness functions**

Situação comum:

Alguém abre uma PR.
Um service da camada de aplicação (por exemplo, `PublishEventService`) instancia e chama diretamente um `KafkaEventPublisher`.
Aí vem o comentário:
*"Esse service não deveria depender diretamente de implementações concretas da infraestrutura, como o KafkaEventPublisher. Verifique o ADR 0003-adotar-arquitetura-hexagonal.md."*

O ponto é: essa decisão já foi tomada. Está documentada.
Não faz sentido depender de alguém lembrar disso e apontar manualmente.

ADR (*Architecture Decision Record*) é um registro formal das decisões arquiteturais tomadas no projeto — uma forma de documentar e justificar as escolhas feitas.

Estou lendo *Software Architecture: The Hard Parts*, e logo no início o livro fala sobre *Fitness Functions*.
A definição formal de *fitness function* é um mecanismo de verificação objetiva da integridade de características arquiteturais.

Ao automatizar essas verificações, você protege sua arquitetura contra violações não intencionais que, acumuladas, levam à deterioração estrutural ao longo do tempo.

Um exemplo simples em Ruby que resolve a situação em uma arquitetura hexagonal:

Nesse estilo, a camada de aplicação (services) deve depender apenas de abstrações definidas por interfaces, e não de implementações concretas como adaptadores externos.

Se sua aplicação usa Kafka para comunicação assíncrona, você pode proteger sua camada de aplicação com uma fitness function como esta:

```ruby
RSpec.describe 'Architecture Fitness - Hexagonal Isolation' do
  it 'impede que o domínio e aplicação acessem adaptadores externos (ex: Kafka) diretamente' do
    # Regex case-insensitive que busca "kafka" como palavra ou parte de palavra
    disallowed_pattern = /kafka/i

    # Define os diretórios onde o acesso direto à infraestrutura é proibido
    restricted_dirs_glob = ['app/domain/**/*.rb', 'app/application/**/*.rb']

    offending_files = []
    restricted_dirs_glob.each do |glob_pattern|
      offending_files.concat(
        Dir.glob(glob_pattern).select do |file|
          # Ignora o próprio adaptador se ele estiver em um dos diretórios por acidente
          next if file.include?('kafka_adapter.rb')

          File.read(file) =~ disallowed_pattern
        end
      )
    end

    expect(offending_files).to be_empty, <<~MSG
      Arquitetura violada! Camadas não autorizadas estão acopladas com detalhes de infraestrutura (Kafka):
      #{offending_files.uniq.join("\n")}
    MSG
  end
end

```

Esse teste busca strings específicas para simplificar o exemplo.

Num cenário real, o ideal é assegurar o isolamento por meio de interfaces e camadas de abstração — isso torna a proteção mais robusta contra mudanças e mais resistente a falsos positivos.

Esse tipo de validação ajuda a garantir o respeito à inversão de dependências, como manda o padrão arquitetural.
Se alguém quebrar essa regra, o CI falha.
A discussão nem começa.

Vale lembrar que *fitness functions* não se limitam à arquitetura. O conceito pode (e deve) ser aplicado a outras dimensões do sistema:

- **Métricas de arquitetura** – Ex.: garantir isolamento de camadas, ausência de ciclos entre módulos, etc.
- **Testes de contrato** – Verificam se integrações entre serviços seguem o contrato esperado, evitando quebras em produção.
- **Métricas de processo** – Ex.: tempo de ciclo ou frequência de deploy ajudam a entender a eficiência da entrega.
- **Métricas de integração** – Validam o comportamento de componentes trabalhando juntos.
- **Testes de unidade** – Garantem qualidade e regressão do código.
- **Monitoração** – Acompanhamento contínuo de disponibilidade, latência, consumo de recursos, etc.

Cada uma dessas categorias pode ser usada para garantir que os princípios definidos no projeto estão sendo respeitados de forma contínua. O conjunto dessas funções forma uma *systemwide fitness function* — uma validação automatizada do sistema como um todo.

#ruby #arquiteturadesoftware #softwarearchitecture #fitnessfunctions #ADR #automacao #arquiteturahexagonal #dev
