# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe AttachmentsController do
    routes { LaissCms::Engine.routes }

    let(:attachment) { create(:laiss_cms_attachment) }

    it "should raise ActiveRecord::RecordNotFound for requesting not existing attachments" do
      expect { get :download, params: {id: 0} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with public attachment" do
      before do
        allow(Attachment).to receive(:find).and_return(attachment)
      end

      it "sends download as attachment." do
        get :download, params: {id: attachment.id}
        expect(response.status).to eq(200)
        expect(response.headers["Content-Disposition"]).to match(/attachment/)
      end

      it "sends download inline." do
        get :show, params: {id: attachment.id}
        expect(response.status).to eq(200)
        expect(response.headers["Content-Disposition"]).to match(/inline/)
      end

      context "with an SVG attachment", if: LaissCms.storage_adapter.active_storage? do
        let(:attachment) do
          create(:laiss_cms_attachment, file: fixture_file_upload("icon.svg", "image/svg+xml"))
        end

        it "serves it with its image content type but forces a download" do
          get :show, params: {id: attachment.id}
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to match(%r{image/svg\+xml})
          expect(response.headers["Content-Disposition"]).to match(/attachment/)
        end
      end

      context "adds Content-Length to header" do
        it "when downloading attachment" do
          get :download, params: {id: attachment.id}
          expect(response.headers["Content-Length"]).to eq(attachment.file_size.to_s)
        end

        it "when showing attachment" do
          get :show, params: {id: attachment.id}
          expect(response.headers["Content-Length"]).to eq(attachment.file_size.to_s)
        end
      end

      context "when Range header is present", if: LaissCms.storage_adapter.active_storage? do
        it "returns partial content" do
          request.headers["Range"] = "bytes=0-35"
          get :download, params: {id: attachment.id}
          expect(response.headers["Content-Range"]).to eq("bytes 0-35/70")
          expect(response.status).to eq(206)
        end
      end
    end

    context "with restricted attachment" do
      before do
        allow(attachment).to receive(:restricted?).and_return(true)
        allow(Attachment).to receive(:find).and_return(attachment)
      end

      context "as anonymous user" do
        it "should not be possible to download attachments from restricted pages" do
          get :download, params: {id: attachment.id}
          expect(response.status).to eq(302)
          expect(response).to redirect_to(LaissCms.config.login_path)
        end

        it "should not be possible to see attachments from restricted pages" do
          get :show, params: {id: attachment.id}
          expect(response.status).to eq(302)
          expect(response).to redirect_to(LaissCms.config.login_path)
        end
      end

      context "as member user" do
        before { authorize_user(build(:laiss_cms_dummy_user, :as_member)) }

        it "should be possible to download attachments from restricted pages" do
          get :download, params: {id: attachment.id}
          expect(response.status).to eq(200)
        end

        it "should be possible to see attachments from restricted pages" do
          get :show, params: {id: attachment.id}
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
