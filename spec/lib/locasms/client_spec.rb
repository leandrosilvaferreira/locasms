require 'spec_helper'

describe LocaSMS::Client do
  let(:rest_client) { 'rest_client mock' }
  subject { LocaSMS::Client.new :login, :password, rest_client: rest_client }

  describe '.initialize' do
    it { expect(subject.login).to be(:login) }
    it { expect(subject.password).to be(:password) }
  end

  describe '#deliver' do
    it 'Should send SMS' do
      expect(subject).to receive(:numbers)
        .once
        .with([:a, :b, :c])
        .and_return('XXX')

      expect(rest_client).to receive(:get)
        .once
        .with(:sendsms, msg: 'given message', numbers:'XXX')
        .and_return({})

      subject.deliver 'given message', :a, :b, :c
    end

    it 'Should not send SMS' do
      expect(subject).to receive(:numbers)
        .once
        .with([:a, :b, :c])
        .and_raise(LocaSMS::Exception)

      expect(rest_client).to receive(:get).never

      expect { subject.deliver('given message', :a, :b, :c) }.to raise_error(LocaSMS::Exception)
    end
  end

  describe '#deliver_at' do
    it 'Should send SMS' do
      expect(subject).to receive(:numbers)
        .once
        .with([:a, :b, :c])
        .and_return('XXX')

      expect(LocaSMS::Helpers::DateTimeHelper).to receive(:split)
        .once
        .with(:datetime)
        .and_return(%w[date time])

      expect(rest_client).to receive(:get)
        .once
        .with(:sendsms, msg: 'given message', numbers:'XXX', jobdate: 'date', jobtime: 'time')
        .and_return({})

      subject.deliver_at 'given message', :datetime, :a, :b, :c
    end

    it 'Should not send SMS' do
      expect(subject).to receive(:numbers)
        .once
        .with([:a, :b, :c])
        .and_raise(LocaSMS::Exception)

      expect(LocaSMS::Helpers::DateTimeHelper).to receive(:split)
        .once
        .with(:datetime)
        .and_return(%w[date time])

      expect(rest_client).to receive(:get).never

      expect { subject.deliver_at('given message', :datetime, :a, :b, :c) }.to raise_error(LocaSMS::Exception)
    end
  end

  describe '#balance' do
    it 'Should check param assignment' do
      expect(rest_client).to receive(:get)
        .once
        .with(:getbalance)
        .and_return({})

      subject.balance
    end
  end

  context 'Testing all campaign based methods' do
    def check_for(method)
      rest_method = {
        campaign_status: :getstatus,
        campaign_hold: :holdsms,
        campaign_release: :releasesms
      }[method]

      expect(rest_client).to receive(:get)
        .once
        .with(rest_method, id: '12345')
        .and_return({})

      subject.send method, '12345'
    end

    it{ check_for :campaign_status  }
    it{ check_for :campaign_hold    }
    it{ check_for :campaign_release }

    it 'Should have tests to cover campaign_status csv result'
  end

end