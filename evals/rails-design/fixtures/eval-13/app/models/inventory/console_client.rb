module Inventory
  class ConsoleClient
    class FetchError < StandardError; end

    BASE_URL = "https://inventory.internal.test/api".freeze

    def fetch_equipment(code)
      conn.get("equipments/#{code}").body
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise FetchError, "在庫コンソールが応答しませんでした: #{e.message}"
    rescue Faraday::Error => e
      raise FetchError, "在庫コンソールの呼び出しに失敗しました: #{e.message}"
    end

    def reserve_equipment(code, employee_code)
      conn.post("equipments/#{code}/reservations", { employee_code: employee_code }).body
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise FetchError, "在庫コンソールが応答しませんでした: #{e.message}"
    rescue Faraday::Error => e
      raise FetchError, "在庫コンソールの呼び出しに失敗しました: #{e.message}"
    end

    def release_equipment(code)
      conn.delete("equipments/#{code}/reservations").body
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise FetchError, "在庫コンソールが応答しませんでした: #{e.message}"
    rescue Faraday::Error => e
      raise FetchError, "在庫コンソールの呼び出しに失敗しました: #{e.message}"
    end

    private

    def conn
      @conn ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json
        f.response :raise_error
      end
    end
  end
end
