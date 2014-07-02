require 'pry'

class UserAgent
  module Browsers
    class Opera < Base
      def self.extend?(agent)
        @@LAST_PIECE = agent.last.to_s
        (agent.first && agent.first.product == 'Opera') ||
        (agent.application && agent.application.product == 'Opera') ||
        (agent.last && agent.last.to_s =~ /OPR/)
      end

      def version
        if mini?
          application.comment.detect{|c| c =~ /Opera Mini/}[/Opera Mini\/([\d\.]+)/, 1] rescue nil
        elsif product = detect_product('Version')
          product.version
        else
          super
        end
      end

      def browser
        "Opera"
      end

      def platform
        if application.comment.nil?
          nil
        elsif application.comment[0] =~ /Windows/
          "Windows"
        else
          application.comment[0]
        end
      end

      def security
        if application.comment.nil?
          :strong
        elsif platform == "Macintosh"
          Security[application.comment[2]]
        elsif mini?
          Security[application.comment[-2]]
        else
          Security[application.comment[1]]
        end
      end

      def mobile?
        mini? || @@LAST_PIECE =~ /OPR/
      end

      def os
        if application.comment.nil?
          nil
        elsif application.comment[0] =~ /Windows/
          OperatingSystems.normalize_os(application.comment[0])
        else
          application.comment[1]
        end
      end

      def localization
        if application.comment.nil?
          nil
        elsif platform == "Macintosh"
          application.comment[3]
        else
          application.comment[2]
        end
      end

      private
        def mini?
          /Opera Mini/ === application
        end
    end
  end
end
