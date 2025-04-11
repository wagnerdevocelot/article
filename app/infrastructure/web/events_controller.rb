# infrastructure/web/events_controller.rb
require_relative '../../application/publish_event_service'
require_relative '../../infrastructure/kafka_event_publisher'

class EventsController
  def create(params)
    publisher = KafkaEventPublisher.new # Adaptador de saída
    service = PublishEventService.new(publisher: publisher) # Casos de uso (aplicação)

    service.call(name: params[:name], data: params[:data]) # Chama o domínio via aplicação

    render json: { status: 'ok' }
  rescue => e
    render json: { error: e.message }, status: 422
  end
end
