RSpec.describe Search do
  it "can derive a machine that increments a binary number" do
    subject.expect(start: 6, input: "______0____", output: "______1____")
    subject.expect(start: 6, input: "______1____", output: "_____10____")
    subject.expect(start: 6, input: "_____10____", output: "_____11____")
    subject.expect(start: 6, input: "_____11____", output: "____100____")
    subject.expect(start: 6, input: "____100____", output: "____101____")
    subject.expect(start: 6, input: "____101____", output: "____110____")
    subject.expect(start: 6, input: "____110____", output: "____111____")

    subject.states = 2
    subject.transitions = 5
    subject.steps_fn = -> (_) { 3 }
    subject.execute

    expect(subject.transition_rules).to eq [
      [0, "0", "1", :R, 1],
      [0, "1", "0", :L, 0],
      [0, "_", "1", :R, 1],
      [1, "0", "0", :R, 1],
      [1, "_", "_", :R, 1],
    ]
  end

  it "can derive a machine that flips bits" do
    subject.expect(start: 4, input: "____0____", output: "____1____")
    subject.expect(start: 4, input: "____1____", output: "____0____")
    subject.expect(start: 5, input: "___110___", output: "___001___")
    subject.expect(start: 5, input: "___101___", output: "___010___")

    subject.states = 1
    subject.transitions = 3
    subject.steps_fn = -> (_) { 3 }
    subject.execute

    expect(subject.transition_rules).to eq [
      [0, "0", "1", :L, 0],
      [0, "1", "0", :L, 0],
      [0, "_", "_", :L, 0],
    ]
  end
end
