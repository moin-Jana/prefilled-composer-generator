RSpec.describe "Prefilled Composer Generator - button test", system: true do
  let!(:theme) do 
    upload_theme_component
  end

  fab!(:user) { Fabricate(:user, trust_level: TrustLevel[1], refresh_auto_groups: true) }
  fab!(:category)
  fab!(:topic_1) { Fabricate(:topic) }
  fab!(:post_1) do
    Fabricate(
      :post,
      raw: "This is an awesome topic",
      topic: topic_1,
      )
  end
  fab!(:post_2) do
    Fabricate(
      :post,
      raw: "This is an awesome reply",
      topic: topic_1,
      )
  end


  before do 
    sign_in(user)
  end
 
  it "copy link button is hidden by group setting" do
    theme.update_setting(:show_groups, "trust_level_4")
    theme.save!
    
    visit("/")
    find("#create-topic").click

    expect(page).to have_no_css(".copy-link-btn")
  end

context "when user is in show_groups group" do
  before do 
    theme.update_setting(:show_groups, "trust_level_1")
    theme.save!
  end
  
    it "composer has copy link button on new topic" do    
      visit("/")
      find("#create-topic").click

      expect(page).to have_css(".copy-link-btn")
    end

    it "copy link button does not appear on replies" do    
      visit("/t/#{topic_1.id}")
      find(".reply").click

      expect(page).to have_no_css(".copy-link-btn")
    end

    it "copy link button does appear when editing first post" do
      visit("/t/#{topic_1.id}")
      find("#post_1 .edit").click

      expect(page).to have_css(".copy-link-btn")
    end

    it "copy link button does not appear when editing non-first post" do
      visit("/t/#{topic_1.id}")
      find("#post_2 .edit").click

      expect(page).to have_no_css(".copy-link-btn")
    end

    it "composer has copy link button on new message" do    
      visit("/?new-message")

      expect(page).to have_css(".copy-link-btn")
    end

    #it "shows education message when sending to more than one group" do
    #  visit("/?new-message")
    #  find()
    #  page.find(".d-modal input.filter").fill_in(with: "jan")
    #end
    
    # clicking clone button shows modal
    # error when user and group
    # error when group and group
    # no error when okay
    # copy link button works
  end
end
