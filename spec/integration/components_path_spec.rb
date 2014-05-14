require "spec_helper"

describe "components_path" do
  before do
    visit components_path
  end

  it "displays G5 Theme Garden" do
    expect(page).to have_content "G5 Theme Garden"
  end

  it "has 6 themes marked up as .h-g5-component" do
    expect(all(".h-g5-component").length).to eq 5
  end

  describe "every theme" do
    it "has a name" do
      all(".h-g5-component").each do |theme|
        expect(theme.find("h2.p-name")).to be_present
      end
    end

    it "has a uid" do
      all(".h-g5-component").each do |theme|
        expect(theme.find(".u-uid")).to be_present
      end
    end

    it "has a summary" do
      all(".h-g5-component").each do |theme|
        expect(theme.find(".p-summary")).to be_present
      end
    end

    it "has a photo" do
      all(".h-g5-component").each do |theme|
        expect(theme.find(".u-photo")).to be_present
      end
    end

    it "have colors" do
      expect(all(".h-g5-component .p-g5-color").length).to be 10
    end
  end

  describe "some themes" do
    it "have targets" do
      pending("This spec should be implemented when a theme goes live with targets")
      expect(all(".h-g5-component .u-g5-target").length).to be 2
    end
  end
end

