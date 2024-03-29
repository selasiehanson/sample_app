# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  	before do
  		@user = User.new(name: "Kwame", email: "kk@gmail.com", password: "foobar", password_confirmation: "foobar")
  	end 
  	subject { @user }

  	it { should respond_to :name} #should contain a name and an email
 	it { should respond_to :email}
 	it { should respond_to :password_digest }
 	it { should respond_to :password }
 	it { should respond_to :password_confirmation }
 	it { should respond_to :remember_token }
 	it { should respond_to :authenticate }
 	it { should respond_to :microposts }
 	it { should respond_to :feed }
 	it { should respond_to :relationships }
 	it { should respond_to :followed_users }
 	it { should respond_to :following? }
 	it { should respond_to :follow! }
 	it { should respond_to :unfollow! }

 	it {should be_valid}

 	describe "when name is not present " do
 		before { @user.name = " "}
 		it {should_not be_valid}
 	end

 	describe "when name is too long" do
 		before { @user.name = "a" * 51}
 		it {should_not be_valid}
 	end

 	describe "when email is not present" do 
 		before { @user.email = " " }
 		it  { should_not be_valid}
 	end

 	describe "when email format is invalid" do
 		it "should be invalid" do
 			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
 				foo@bar_baz.com foo@bar+baz.com
 			]

 			addresses.each do |invalid_address|
 				@user.email = invalid_address
 				@user.should_not be_valid
 			end
 		end
 	end

 	describe "when email format is valid" do
 		it "should be valid" do
 			addresses = %w[user@foo.COM A_US-ER@f.b.org fst.last@foo.jp a+b@baz.cn]
 			addresses.each	do |valid_address|
 				@user.email = valid_address
 				@user.should be_valid
 			end
 		end
 	end


 	describe "when email address is already taken" do
 		before do
 			user_wtih_same_email = @user.dup
 			user_wtih_same_email.email = @user.email.upcase
 			user_wtih_same_email.save
 		end

 		it {should_not be_valid}
 	end

 	describe "password is not present " do 
 		before { @user.password =  @user.password_confirmation = " "}
 		it { should_not be_valid }
 	end

 	describe "when password does not match confirmation" do
 		before { @user.password_confirmation = "mismatch"}
 		it {should_not be_valid}
 	end

 	describe "when password is nil" do
 		before { @user.password_confirmation = nil }
 		it { should_not be_valid }
 	end

 	describe "return value of authenticate method" do
 		before  { @user.save }
 		let(:found_user) { User.find_by_email( @user.email) }

 		describe  "with valid password" do
 			it { should == found_user.authenticate(@user.password) }
 		end

 		describe "with invalid password" do
 			let(:user_for_invalid_password) { found_user.authenticate("invalid") }

 			it { should_not == user_for_invalid_password }
 			specify {user_for_invalid_password.should be_false }
 		end
 	end

 	describe "with a password thats too short" do
 		before { @user.password = @user.password_confirmation =  "a" * 5 }
 		it { should_not be_valid }
 	end

 	describe "remeber token" do
 		before { @user.save }
 		its(:remember_token) {  should_not be_blank }
 	end

 	it { should respond_to(:admin) }
 	it { should respond_to(:authenticate) }

 	it { should be_valid }
 	it { should_not be_admin }

 	describe "with admin attribute set to true" do
 		before	do
 			@user.save!
 			@user.toggle!(:admin)
 		end

 		it { should be_admin }
 	end

 	describe "microposts association" do
 		before { @user.save }
 		let!(:older_micropost) do
 			FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago )
 		end

 		let!(:newer_micropost) do
 			FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago )
 		end

 		it "should have the micropost in the right order" do
 			@user.microposts == [newer_micropost, older_micropost]
 		end

 		it "should destroy assocciated microposts" do
 			microposts = @user.microposts.dup
 			@user.destroy
 			microposts.should_not be_empty
 			microposts.each do |micropost|
 				Micropost.find_by_id(micropost.id).should be_nil
 			end
 		end

 		describe "status" do
 			let(:unfollowed_post) do
 				FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
 			end

 			its(:feed) { should include(newer_micropost) }
 			its(:feed) { should include(older_micropost) }
 			its(:feed) { should_not include(unfollowed_post) }
 		end
 	end 

 	describe "following" do
 		let(:other_user) { FactoryGirl.create(:user) }
 		before do
 			@user.save
 			@user.follow!(other_user)
 		end

 		it { should be_following(other_user) }
 		its(:followed_users) { should include(other_user) }

 		describe "and unfollowing" do
 			before { @user.unfollow!(other_user) }
 			it { should_not be_following(other_user) }
 			its(:followed_users) { should_not include(other_user) }
 		end
 	end

 	
end
