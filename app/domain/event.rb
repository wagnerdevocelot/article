# domain/event.rb
class Event
  attr_reader :name, :data, :occurred_at

  def initialize(name:, data:)
    @name = name
    @data = data
    @occurred_at = Time.now
  end

  def valid?
    !name.nil? && !data.nil?
  end

  def normalize
    Event.new(name: name.strip.downcase, data: data)
  end
end
