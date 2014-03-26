require 'awesome_print'

module Trellohub
  module Mocking
    class << self
      attr_reader :called_requests

      def start
        ::Octokit::Client.__send__ :include, NoRequest
        ::Trell::Client.__send__ :include, NoRequest
      end

      def stop
        ::Octokit::Client.__send__ :include, Request
        ::Trell::Client.__send__ :include, Request
      end

      def request_methods
        %i(post put patch delete)
      end

      def push_called_request(klass, method, path)
        @called_requests = {} if @called_requests.nil?
        @called_requests[klass] = {} if @called_requests[klass].nil?
        @called_requests[klass][method] = [] if @called_requests[klass][method].nil?

        @called_requests[klass][method] << path
      end

      def print_request_summary
        ap " Request Summary ".center(80, '=')
        klasses = @called_requests.keys
        klasses.each do |klass|
          methods = @called_requests[klass].keys
          methods.each do |method|
            ap "#{klass} #{method.upcase}: #{@called_requests[klass][method].count}"
          end
        end
      end

      def overriding_method(http_method)
        <<-METHOD
          def #{http_method}_without_http(url, options = {})
            Trellohub::Mocking.print_request(self.class.name, "#{http_method}", url, options)
          end
        METHOD
      end

      def print_request(klass, method, path, *body)
        push_called_request(klass, method, path)

        ap " #{klass} #{method.upcase} #{path} ".center(80, '-')
        ap body
      end
    end

    module Request
      def self.included(base)
        Trellohub::Mocking.request_methods.each do |m|
          base.class_eval do
            alias_method m.to_sym, :"#{m}_with_http" if method_defined? :"#{m}_with_http"
          end
        end
      end
    end

    module NoRequest
      Trellohub::Mocking.request_methods.each do |http_method|
        class_eval Trellohub::Mocking.overriding_method(http_method),
          __FILE__,
          __LINE__ + 1
      end

      def self.included(base)
        Trellohub::Mocking.request_methods.each do |m|
          base.class_eval do
            alias_method :"#{m}_with_http", m.to_sym unless method_defined? :"#{m}_with_http"
            alias_method m.to_sym, :"#{m}_without_http"
          end
        end
      end
    end
  end
end
