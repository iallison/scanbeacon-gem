require 'spec_helper'
require 'scan_beacon'

RSpec.describe ScanBeacon::BLE112Scanner do
  let(:buffer) {
    "\x80*\x06\x00\xAC\x02\xB3\x89\x9C\x9B\xF0\xDD\x01\xFF\x1F\x02\x01\x06\e\xFF\x18\x01\xBE\xAC,\xBC&\eJ\aBx\xA5\x13\x8B\xF3\xF8\x01#t\x00\xC8\x00Q\xC4b".force_encoding("ASCII-8BIT")
  }
  let(:scanner_opts) { {port: "/dev/null", cycle_seconds: 0} }
  let(:response) { ScanBeacon::BLE112Device::BLE112Response.new(buffer) }

  before do
    allow_any_instance_of(ScanBeacon::BLE112Device).to receive(:start_scan)
    allow_any_instance_of(ScanBeacon::BLE112Device).to receive(:stop_scan)
    allow_any_instance_of(ScanBeacon::BLE112Device).to receive(:read).and_return(response)
    allow_any_instance_of(ScanBeacon::BLE112Device).to receive(:get_addr).and_return("00:11:22:33:44:55")
  end

  it "can scan for altbeacons" do
    scanner = ScanBeacon::BLE112Scanner.new scanner_opts
    expect {
      scanner.scan
    }.to change { scanner.beacons.size }.by(1)
  end

  it "can use a beacon parser to parse an altbeacon" do
    scanner = ScanBeacon::BLE112Scanner.new scanner_opts
    scanner.scan
    expect( scanner.beacons[0].uuid ).to eq("2CBC261B-4A07-4278-A513-8BF3F8012374")
  end

  it "can be initialized with an array of parsers" do
    foo_parser = ScanBeacon::BeaconParser.new(:foo, "m:2-3=f000,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25")
    scanner = ScanBeacon::BLE112Scanner.new({parsers: [foo_parser]}.merge(scanner_opts))
    expect( scanner.parsers ).to eq([foo_parser])
  end
end
