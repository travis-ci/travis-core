class Job
  module Sponsors
    SPONSORS = {
      'erlang.worker.travis-ci.org' => {
        'name' => 'TTY',
        'url' => 'http://www.tty.nl'
      },
      'nodejs1.worker.travis-ci.org' => {
        'name' => 'Shopify',
        'url' => 'http://www.shopify.com'
      },
      'php1.worker.travis-ci.org' => {
        'name' => 'ServerGrove',
        'url' => 'http://servergrove.com'
      },
      'rails1.worker.travis-ci.org' => {
        'name' => 'Engine Yard',
        'url' => 'http://www.engineyard.com'
      },
      'rails2.worker.travis-ci.org' => {
        'name' => 'Engine Yard',
        'url' => 'http://www.engineyard.com'
      },
      'ruby1.worker.travis-ci.org' => {
        'name' => 'EnterpriseRails',
        'url' => 'http://www.enterprise-rails.com'
      },
      'ruby2.worker.travis-ci.org' => {
        'name' => 'EnterpriseRails',
        'url' => 'http://www.enterprise-rails.com'
      },
      'ruby3.worker.travis-ci.org' => {
        'name' => 'Railslove',
        'url' => 'http://railslove.de'
      },
      'spree.worker.travis-ci.org' => {
        'name' => 'Spree',
        'url' => 'http://spreecommerce.com'
      },
      'staging.worker.travis-ci.org' => {
        'name' => 'EnterpriseRails',
        'url' => 'http://www.enterprise-rails.com'
      }
    }

    def sponsor
      Hashr.new(SPONSORS[worker.split(':').first] || {})
    end

    # TODO this overwrites the activerecord attribute which currently is not populated from the actual worker
    # we should be able to remove this once https://github.com/travis-ci/travis-worker/commit/dcee841d1be7808131395c0976a075c58392a624
    # is in production
    def worker
      read_attribute(:worker) || extract_worker || ''
    end

    protected

      def extract_worker
        (log.content || '').split("\n").first =~ /Using worker: (.+)/ and $1
      end
  end
end

