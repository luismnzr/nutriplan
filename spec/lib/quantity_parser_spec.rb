require "rails_helper"
require Rails.root.join("app/lib/quantity_parser")

RSpec.describe QuantityParser do
  describe ".parse" do
    it "parses integer + unit" do
      expect(described_class.parse("1 taza")).to eq([1.0, "taza"])
    end

    it "parses decimal + unit (dot or comma)" do
      expect(described_class.parse("1.5 taza")).to eq([1.5, "taza"])
      expect(described_class.parse("1,5 taza")).to eq([1.5, "taza"])
    end

    it "parses fractions" do
      n, u = described_class.parse("1/2 taza")
      expect(n).to be_within(0.001).of(0.5)
      expect(u).to eq("taza")
    end

    it "handles no unit" do
      expect(described_class.parse("3")).to eq([3.0, ""])
    end

    it "returns nil number for non-numeric leading text" do
      n, _ = described_class.parse("al gusto")
      expect(n).to be_nil
    end

    it "returns [nil, nil] for blank" do
      expect(described_class.parse("")).to eq([nil, nil])
      expect(described_class.parse(nil)).to eq([nil, nil])
    end

    it "lowercases the unit for grouping" do
      expect(described_class.parse("1 TAZA")).to eq([1.0, "taza"])
    end
  end

  describe ".aggregate" do
    it "sums matching units" do
      expect(described_class.aggregate(["1 taza", "2 taza"])).to eq("3 taza")
    end

    it "sums fractional with integer of the same unit" do
      expect(described_class.aggregate(["1/2 taza", "1 taza"])).to eq("1.5 taza")
    end

    it "keeps different units separated with ' + '" do
      expect(described_class.aggregate(["1 taza", "200 g"])).to eq("1 taza + 200 g")
    end

    it "appends unparseable entries verbatim" do
      expect(described_class.aggregate(["1 taza", "al gusto"])).to eq("1 taza + al gusto")
    end

    it "ignores blanks" do
      expect(described_class.aggregate(["", nil, "1 taza"])).to eq("1 taza")
    end

    it "emits plain number when there is no unit" do
      expect(described_class.aggregate(["1", "2"])).to eq("3")
    end
  end
end
