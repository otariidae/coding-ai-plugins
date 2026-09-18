# frozen_string_literal: true

# 新規エンドポイントでは利用せず ApplicationSerializer を使うこと
class ApplicationLegacySerializer
  include JSONAPI::Serializer
end
