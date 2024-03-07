module UtilityService
  module South
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        utility_params(params)
      end

      def retrieve_notes(params)
        utility_params(params)
      end

      private

      def utility_params(params)
        { Autor: params['author'] }
      end
    end
  end
end
