# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Overphishing::MailParser::ReceivedHeaders::ByParser do
  let(:enriched_ip_1) { instance_double(Overphishing::ExtendedIp) }
  let(:enriched_ip_factory) do
    instance_double(Overphishing::ExtendedIpFactory).tap do |factory|
      allow(factory).to receive(:build) do |arg|
        arg == '10.0.0.1' ? enriched_ip_1 : nil
      end
    end
  end
  let(:sample_1) do
    'by mx.google.com with ESMTPS id u23si16237783eds.526.2020.06.26.06.27.53 '
  end
  let(:sample_2) do
    'by still.dodgy.host.com (8.14.7/8.14.7/Submit) id 05QDRrso001911 '
  end
  let(:sample_3) do
    'by 10.0.0.1 Fuzzy Corp with SMTP id 3gJek488nka743gKRkR2nY'
  end
  let(:sample_4) do
    ' by mx.google.com (8.14.7/8.14.7) with ESMTP id b201si8173212pfb.88.2020.04.25.22.14.05 '
  end
  let(:sample_5) do
    'by foo.bar-host.baz (Postfix, from userid 0) '
  end

  subject  { described_class.new(enriched_ip_factory) }

  it 'nil' do
    expect(subject.parse(nil)).to eql({
      recipient: nil, recipient_additional: nil, protocol: nil, id: nil
    })
  end

  it 'sample 1' do
    expect(subject.parse(sample_1)).to eql({
      recipient: 'mx.google.com',
      recipient_additional: nil,
      protocol: 'ESMTPS',
      id: 'u23si16237783eds.526.2020.06.26.06.27.53',
    })
  end

  it 'sample 2' do
    expect(subject.parse(sample_2)).to eql({
      recipient: 'still.dodgy.host.com',
      protocol: nil,
      recipient_additional: '8.14.7/8.14.7/Submit',
      id: '05QDRrso001911',
    })
  end

  it 'sample 3' do
    expect(subject.parse(sample_3)).to eql({
      recipient: enriched_ip_1,
      recipient_additional: 'Fuzzy Corp',
      protocol: 'SMTP',
      id: '3gJek488nka743gKRkR2nY',
    })
  end

  it 'sample 4' do
    expect(subject.parse(sample_4)).to eql({
      recipient: 'mx.google.com',
      recipient_additional: '8.14.7/8.14.7',
      protocol: 'ESMTP',
      id: 'b201si8173212pfb.88.2020.04.25.22.14.05'
    })
  end

  it 'sample 5' do
    expect(subject.parse(sample_5)).to eql({
      recipient: 'foo.bar-host.baz',
      recipient_additional: 'Postfix, from userid 0',
      protocol: nil,
      id: nil,
    })
  end
end
