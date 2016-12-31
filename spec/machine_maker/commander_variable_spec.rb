RSpec.describe CommanderVariable do
  let(:io) { StringIO.new }
  let(:cnf) { io.string.split("\n") }

  it "works for one variable" do
    subject.exactly_one(%w(a), io)
    expect(cnf).to eq(%w(a))
  end

  it "works for two variables" do
    subject.exactly_one(%w(a b), io)
    expect(cnf).to eq ["a b", "-a -b"]
  end

  it "works for three variables" do
    subject.exactly_one(%w(a b c), io)
    expect(cnf).to eq [
      "a b c",
      "-a -b",
      "-a -c",
      "-b -c",
    ]
  end

  it "works for four variables" do
    subject.exactly_one(%w(a b c d), io)

    expect(cnf).to eq [
      "a b c -Com_1",
      "-a -b",
      "-a -c",
      "-a Com_1",
      "-b -c",
      "-b Com_1",
      "-c Com_1",
      "d -Com_2",
      "-d Com_2",
      "Com_1 Com_2",
      "-Com_1 -Com_2",
    ]
  end

  it "works for six variables" do
    subject.exactly_one(%w(a b c d e f), io)

    expect(cnf).to eq [
      "a b c -Com_1",
      "-a -b",
      "-a -c",
      "-a Com_1",
      "-b -c",
      "-b Com_1",
      "-c Com_1",
      "d e f -Com_2",
      "-d -e",
      "-d -f",
      "-d Com_2",
      "-e -f",
      "-e Com_2",
      "-f Com_2",
      "Com_1 Com_2",
      "-Com_1 -Com_2",
    ]
  end

  it "works for a lot of variables quickly" do
    n = 10_000

    time_taken = Benchmark.realtime do
      subject.exactly_one((1..n).map(&:to_s).to_a, io)
    end

    expect(cnf.size).to be_within(10).of(3.5 * n)
    expect(time_taken).to be < 0.5
  end
end
