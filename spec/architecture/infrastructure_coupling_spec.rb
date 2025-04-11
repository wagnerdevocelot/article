# frozen_string_literal: true

require_relative '../spec_helper'

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
