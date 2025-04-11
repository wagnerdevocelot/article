# application/publish_event_service.rb
require_relative '../domain/event'
require_relative '../infrastructure/kafka_event_publisher' # viola o princípio de isolamento de camadas trazendo a infraestrutura para a camada de aplicação
class PublishEventService
  def initialize(publisher: KafkaEventPublisher.new) # viola o princípio de isolamento de camadas trazendo a infraestrutura para a camada de aplicação
    @publisher = publisher
  end

  def call(name:, data:)
    event = Event.new(name: name, data: data)

    raise "Evento inválido" unless event.valid?

    normalized_event = event.normalize

    @publisher.publish(normalized_event)
  end
end
