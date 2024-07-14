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
        model: "gpt-3.5-turbo",
        messages: [
            { role: "system",
            content: "入力された内容を厳密に要約してください。絶対に情報を追加しないでください。質問や推測、対策案、メリット、注意点などは一切追加しないでください。日本語で出力してください。"
          },
            { role: "user",
            content:
              "以下のコンテンツを、マークダウンでわかりやすくまとめてください。#{input_content}
              小見出しは必ず番号付きで、番号と小見出し全体を**で囲んで太字にしてください（例：**1. 小見出し**）。
              小見出しの数が少なすぎないように注意し、内容は箇条書きで簡潔にまとめてください。
              ただし、入力内容にない情報を追加せず、日本語で出力してください。

              例1:
              #入力
              衣装の選び方に迷っている、どうしたら良いかな〜〜 バンドの練習日程どうしよう

              #出力
              **1. 衣装の選び方**
              - 迷っている
              **2. バンドの練習日程**
              - 検討中

              例2:
              #入力
              今日はバンド練習お疲れ様でした。Aメロの部分はギターが走りすぎないように気をつけてください。キーボードとボーカルはお互いが聞き合うにしましょう。ベースはもう少し音量が大きめでも問題ないです。
              次回の練習は7月20日に渋谷のスタジオで実施します。忘れないようにお願いします

              #出力
              **1. 演奏の注意点**
              - Aメロの部分はギターが走りすぎないように
              - キーボードとボーカルはお互いが聞き合う
              - ベースはもう少し音量が大きめでも問題ない
              
              **2. バンドの練習日程**
              - 7/20
              - 忘れないように。
              "
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
