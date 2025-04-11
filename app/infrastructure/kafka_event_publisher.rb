# infrastructure/kafka_event_publisher.rb
class KafkaEventPublisher
  def publish(event)
    kafka = KafkaProducer.new
    kafka.publish('event_topic', event_payload(event))
  end

  private

  def event_payload(event)
    {
      name: event.name,
      data: event.data,
      occurred_at: event.occurred_at
    }.to_json
  end
end
