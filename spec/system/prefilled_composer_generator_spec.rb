RSpec.describe "Prefilled Composer Generator - button test", system: true do
  let!(:theme) do 
    upload_theme_component
  end

  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[3], refresh_auto_groups: true) }
  fab!(:category)
  fab!(:topic_1) { Fabricate(:topic) }
  fab!(:post_1) do
    Fabricate(
      :post,
      raw: "This is an awesome topic",
      topic: topic_1,
      )
  end

  before do 
    sign_in(user)
  end
 
  it "copy link button is hidden by group setting" do
    theme.update_setting(:show_groups, "trust_level_4")
    theme.save!
    
    visit("/c/#{category.id}") # needed?
    find("#create-topic").click

    expect(page).to have_no_css(".copy-link-btn")
  end

context "when user is in show_groups group" do
  before do 
    theme.update_setting(:show_groups, "trust_level_3")
    theme.save!
  end
  
    it "composer has copy link button on home" do    
      visit("/") # needed?
      find("#create-topic").click

      expect(page).to have_css(".copy-link-btn")
    end

     it "composer has copy link button in category" do    
      visit("/c/#{category.id}") # needed?
      find("#create-topic").click

      expect(page).to have_css(".copy-link-btn")
    end

    it "copy link button does not appear on replies" do    
      visit("/t/#{topic_1.id}")
      find(".reply").click

      expect(page).to have_no_css(".copy-link-btn")
    end
  end
end
