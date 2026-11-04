require "rails_helper"

RSpec.describe LaissCms do
  describe ".version" do
    subject { LaissCms.version }

    it { is_expected.to eq(LaissCms::VERSION) }
  end

  describe ".gem_version" do
    subject { LaissCms.gem_version }

    it { is_expected.to eq(Gem::Version.new(LaissCms::VERSION)) }
  end

  describe ".git_revision_info" do
    subject { LaissCms.git_revision_info }

    let(:sources) { [source] }

    before do
      allow(Bundler).to receive(:locked_gems).and_return(double(sources: sources))
    end

    context "when the laiss_cms gem is locked to a git source" do
      let(:source) do
        double(name: "laiss_cms", revision: "abc1234def5678", branch: "main")
      end

      it "returns the revision and branch" do
        is_expected.to eq(revision: "abc1234def5678", branch: "main")
      end
    end

    context "when the laiss_cms gem is not locked to a git source" do
      let(:source) { double(name: "laiss_cms") }

      it { is_expected.to be_nil }
    end

    context "when there is no laiss_cms source" do
      let(:sources) { [double(name: "another_gem")] }

      it { is_expected.to be_nil }
    end

    context "when reading the lockfile raises an error" do
      let(:sources) { [] }

      before do
        allow(Bundler).to receive(:locked_gems).and_raise(StandardError)
      end

      it { is_expected.to be_nil }
    end
  end

  describe ".preview_sources" do
    subject { LaissCms.preview_sources }

    it "returns a Set of preview sources" do
      LaissCms::Deprecation.silence do
        is_expected.to be_a(LaissCms::Configuration::CollectionOption)
      end
    end
  end

  describe ".config" do
    subject { LaissCms.config }

    it "is a config object" do
      expect(subject).to be_a(LaissCms::Configurations::Main)
    end

    it "has the auto_logout_time from config.yml" do
      expect(subject.auto_logout_time).to eq(40)
    end

    it "has the output_image_quality from test.config.yml" do
      expect(subject.output_image_quality).to eq(85)
    end

    it "has the default image output format" do
      expect(subject.image_output_format).to eq("original")
    end

    describe "format matchers" do
      describe "email" do
        subject { LaissCms.config.format_matchers.email }

        it { is_expected.to match("hello@gmail.com") }
        it { is_expected.not_to match("stulli@gmx") }
      end

      describe "url" do
        subject { LaissCms.config.format_matchers.url }

        it { is_expected.to match("www.example.com:80/about") }
        it { is_expected.not_to match('www.example.com:80\/about') }
      end

      describe "link_url" do
        subject { LaissCms.config.format_matchers.link_url }

        it { is_expected.to match("tel:12345") }
        it { is_expected.to match("mailto:stulli@gmx.de") }
        it { is_expected.to match("/home") }
        it { is_expected.to match("https://example.com/home") }
        it { is_expected.not_to match('\/brehmstierleben') }
        it { is_expected.not_to match('https:\/\/example.com/home') }
      end
    end
  end

  describe "admin_importmaps" do
    subject { LaissCms.config.admin_importmaps }
    it "includes laiss_cms_admin importmap" do
      expect(subject.first.to_h).to eq({
        importmap_path: LaissCms::Engine.root.join("config/importmap.rb"),
        name: "laiss_cms_admin",
        source_paths: [
          LaissCms::Engine.root.join("app/javascript"),
          LaissCms::Engine.root.join("vendor/javascript")
        ]
      })
    end
  end

  describe ".configure" do
    subject do
      LaissCms.configure do |config|
        config.auto_logout_time = 500
      end
    end

    around do |example|
      old_auto_logout_time = LaissCms.config.auto_logout_time
      example.run
      LaissCms.config.auto_logout_time = old_auto_logout_time
    end

    it "yields the config object" do
      expect { subject }.to change(LaissCms.config, :auto_logout_time).to(500)
    end
  end

  describe "deprecated: Config" do
    subject { LaissCms::Config }

    it "is the same as LaissCms.config, but deprecated" do
      expect(LaissCms::Deprecation).to receive(:warn)
      expect(LaissCms::Config).to eq(LaissCms.config)
    end
  end

  describe "legacy configuration methods" do
    around do |example|
      LaissCms::Deprecation.silence { example.run }
    end
    describe ".enable_searchable" do
      it "forwards to config.page_searchable_checkbox" do
        expect do
          LaissCms.enable_searchable = true
        end.to change(LaissCms.config, :show_page_searchable_checkbox).to(true)
        # Reset
        expect do
          LaissCms.enable_searchable = false
        end.to change(LaissCms, :enable_searchable).to(false)
      end
    end

    describe ".user_class_primary_key" do
      subject { LaissCms.user_class_primary_key }

      it { is_expected.to eq(:id) }
    end

    describe ".user_class_primary_key=" do
      subject { LaissCms.user_class_primary_key = :uuid }

      around do |example|
        old_user_class_primary_key = LaissCms.config.user_class_primary_key
        example.run
        LaissCms.config.user_class_primary_key = old_user_class_primary_key
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.user_class_primary_key }.from(:id).to(:uuid)
      end
    end

    describe ".current_user_method" do
      subject { LaissCms.current_user_method }

      it { is_expected.to eq(:current_user) }
    end

    describe ".current_user_method=" do
      subject { LaissCms.current_user_method = :my_current_user }

      around do |example|
        real_current_user_method = LaissCms.config.current_user_method
        example.run
        LaissCms.config.current_user_method = real_current_user_method
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.current_user_method }.from(:current_user).to(:my_current_user)
      end
    end

    describe ".signup_path" do
      subject { LaissCms.signup_path }

      it { is_expected.to eq("/signup") }
    end

    describe ".signup_path=" do
      subject { LaissCms.signup_path = "/register" }

      around do |example|
        real_signup_path = LaissCms.config.signup_path
        example.run
        LaissCms.config.signup_path = real_signup_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.signup_path }.from("/signup").to("/register")
      end
    end

    describe ".login_path" do
      subject { LaissCms.login_path }

      it { is_expected.to eq("/login") }
    end

    describe ".login_path=" do
      subject { LaissCms.login_path = "/sign_in" }

      around do |example|
        real_login_path = LaissCms.config.login_path
        example.run
        LaissCms.config.login_path = real_login_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.login_path }.from("/login").to("/sign_in")
      end
    end

    describe ".logout_path" do
      subject { LaissCms.logout_path }

      it { is_expected.to eq("/logout") }
    end

    describe ".logout_path=" do
      subject { LaissCms.logout_path = "/leave" }

      around do |example|
        real_logout_path = LaissCms.config.logout_path
        example.run
        LaissCms.config.logout_path = real_logout_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.logout_path }.from("/logout").to("/leave")
      end
    end

    describe ".logout_method" do
      subject { LaissCms.logout_method }

      it { is_expected.to eq("delete") }
    end

    describe ".logout_method=" do
      subject { LaissCms.logout_method = "get" }

      around do |example|
        real_logout_method = LaissCms.config.logout_method
        example.run
        LaissCms.config.logout_method = real_logout_method
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.logout_method }.from("delete").to("get")
      end
    end

    describe ".unauthorized_path" do
      subject { LaissCms.unauthorized_path }

      it { is_expected.to eq("/") }
    end

    describe ".unauthorized_path=" do
      subject { LaissCms.unauthorized_path = "/nope" }

      around do |example|
        real_unauthorized_path = LaissCms.config.unauthorized_path
        example.run
        LaissCms.config.unauthorized_path = real_unauthorized_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { LaissCms.config.unauthorized_path }.from("/").to("/nope")
      end
    end

    describe ".user_class" do
      subject { LaissCms.user_class }

      it "calls out to the main configuration" do
        expect(LaissCms.config).to receive(:user_class)
        subject
      end
    end

    describe ".user_class_name" do
      subject { LaissCms.user_class_name }

      it "calls out to the main configuration" do
        expect(LaissCms.config).to receive(:user_class_name)
        subject
      end
    end

    describe ".user_class_name=" do
      subject { LaissCms.user_class_name = "MyUserClass" }

      it "calls out to the main configuration" do
        expect(LaissCms.config).to receive(:user_class=).with("MyUserClass")
        subject
      end
    end

    describe ".register_ability" do
      let(:klass) { double }
      subject { LaissCms.register_ability(double(name: "MyAbility")) }

      it "calls config.abilities.add" do
        expect(LaissCms.config.abilities).to receive(:add)
        subject
      end
    end

    describe ".registered_abilities" do
      subject { LaissCms.registered_abilities }

      it "calls out to config.abilities" do
        expect(LaissCms.config).to receive(:abilities)
        subject
      end
    end
  end
end
