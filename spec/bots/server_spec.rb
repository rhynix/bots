# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Bots::Server do
  include Rack::Test::Methods

  let(:app)         { described_class }
  let(:parsed_body) { JSON.parse(last_response.body) }

  describe "POST /" do
    context "request body is absent" do
      let(:body) { "" }

      it "responds with bad request" do
        post "/", body

        expect(last_response.status).to eq(400)
      end

      it "renders an error" do
        post "/", body

        expect(parsed_body).to eq({ "error" => "bad request" })
      end
    end

    context "request body is not json" do
      let(:body) { "<instructions><instructions />" }

      it "responds with bad request" do
        post "/", body

        expect(last_response.status).to eq(400)
      end

      it "renders an error" do
        post "/", body

        expect(parsed_body).to eq({ "error" => "bad request" })
      end
    end

    context "request body does not match schema" do
      let(:body) { JSON.dump({ "instructions" => {} }) }

      it "responds with bad request" do
        post "/", body

        expect(last_response.status).to eq(400)
      end

      it "renders an error" do
        post "/", body

        expect(parsed_body).to eq({ "error" => "bad request" })
      end
    end

    context "request body contains validator error" do
      let(:body) do
        JSON.dump([
          "value 1 goes to output 1",
          "value 2 goes to output 1"
        ])
      end

      it "responds with bad request" do
        post "/", body

        expect(last_response.status).to eq(400)
      end

      it "renders an error" do
        post "/", body

        expect(parsed_body).to eq({
          "errors" => [
            "output(1) received multiple values: 1, 2"
          ]
        })
      end
    end

    context "request body is valid" do
      let(:body) do
        JSON.dump([
          "value 1 goes to output 1",
          "value 2 goes to output 2"
        ])
      end

      it "responds with ok" do
        post "/", body

        expect(last_response.status).to eq(200)
      end

      it "renders the state" do
        post "/", body

        expect(parsed_body).to eq({
          "log" => [
            "1 goes to output(1)",
            "2 goes to output(2)"
          ],
          "world" => {
            "output(1)" => [1],
            "output(2)" => [2]
          }
        })
      end
    end
  end
end
