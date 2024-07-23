require "openai"

class SummariesController < ApplicationController
  before_action :set_summary, only: %i[edit update destroy]

  def index
    @summaries = current_user.summaries.order(created_at: :desc)
  end

  def show
    @summary = current_user.summaries.find(params[:id])
  end

  def new
    @summary = Summary.new
  end

  def create
    client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

    input_content = summary_params[:content]

    # 入力内容が10文字以下の場合はそのまま出力
    if input_content.length < 10
      summary_text = input_content
    else
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            { role: "system",
            content: 
            "あなたは、入力された情報を厳密に要約するAIアシスタントです。以下の条件に従って、要約を行ってください：
            1. 入力された内容を厳密に要約すること。
            2. 書いてない情報は絶対追加しないこと（質問や推測、対策案、メリット、注意点なども一切追加しない）。
            3. #{input_content}の内容を、必ず・を用いた箇条書きで簡潔にまとめること(例: ・内容1)。
            4. ・を用いた1つの箇条書きには、1つの情報のみを入れること。
            5. 小見出しは必ず番号付きで、番号と小見出し全体を**で囲んで太字にすること（例: **1. 小見出し**）。
            6. 小見出しの数が少なすぎないように注意すること。
            7. 各小見出しの直後には、必ず改行を入れること
            8. ・を用いた箇条書き同士の間には、必ず改行を入れること
            9. 各小見出しでまとめられた項目の直後には、必ず改行を入れること。
            10. 各行の間には、必ず空行は作らない。
            "
          },
            { role: "user",
            content:
              "以下の内容を要約してください。
              #{input_content}"
            },
          ],
        })
    summary_text = response.dig("choices", 0, "message", "content")
    end

    @summary = current_user.summaries.new(title: summary_params[:title], content: summary_params[:content], summary: summary_text)

    if @summary.save
      redirect_to summaries_path, notice: 'メモが保存されました'
    else
      flash.now[:alert] = 'メモの保存ができませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @summary.update(summary_params)
      redirect_to summaries_path, notice: 'メモが更新されました'
    else
      flash.now[:alert] = 'メモを更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    summary = @summary
    summary.destroy!
    redirect_to summaries_path, status: :see_other, notice: 'メモが削除されました'
  end

  private

  def set_summary
    @summary = current_user.summaries.find(params[:id])
  end

  def summary_params
    params.require(:summary).permit(:content, :summary, :title)
  end
end
