# application/publish_event_service.rb
require_relative '../domain/event'
require_relative '../infrastructure/kafka_event_publisher'
class PublishEventService
  def initialize(publisher: KafkaEventPublisher.new)
    @publisher = publisher
  end

  def call(name:, data:)
    event = Event.new(name: name, data: data)

    raise "Evento inválido" unless event.valid?

    normalized_event = event.normalize

    @publisher.publish(normalized_event)
  end
end
