module TransilienRealtime
  # Important note about attribute departure_at:
  # Since it's not possible to have a Time instance w/o timezone, and Europe/Paris change its offset w/ DST,
  # lie by forcing a false UTC hours
  class Train
    include Comparable

    MODES  = {
               'R' => 'realtime',
               'T' => 'theoritical'
             }
    STATES = {
               'R' => 'late',
               'S' => 'cancelled',
             }

    attr_reader :mission, :departure_at, :terminus, :numero, :mode, :state

    class << self
      def from_xml(xml_node)
        attr = {}
        attr[:mission] = xml_node.at_xpath('miss').text
        attr[:terminus] = xml_node.at_xpath('term').text
        attr[:numero] = xml_node.at_xpath('num').text
        date_node = xml_node.at_xpath('date')
        attr[:departure_at] = date_node.text
        attr[:mode] = date_node.attr('mode')
        etat = xml_node.at_xpath('etat')
        attr[:state] = etat.text if etat
        train = new(attr).freeze
      end
    end

    def initialize(mission:, departure_at:, terminus:, numero:, mode:, state: nil)
      @mission = mission
      @numero = numero
      @departure_at = Time.strptime(departure_at + ' +0000', '%d/%m/%Y %H:%M %z')
      @terminus = terminus
      @mode = MODES[mode]
      @state = STATES[state]
    end

    def to_json(options={})
      json = { mission: mission, departure_at: departure_at, numero: numero, terminus: terminus, mode: mode }
      json[:state] = state if state
      json.to_json
    end

    def <=>(other)
      return 0 if mission == other.mission &&
                  departure_at == other.departure_at &&
                  terminus == other.terminus &&
                  numero == other.numero &&
                  mode == other.mode && 
                  state == other.state
      departure_at <=> other.departure_at
    end

  end
end
