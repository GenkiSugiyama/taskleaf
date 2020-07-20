require 'rails_helper'

# letを使って変数（のようなもの）に値を代入する
# let(定義名) {定義の内容}
# letで定義したものはその外側でも内側でも使用することができる

describe 'タスク管理機能', type: :system do
  describe ('一覧表示機能') do

    # 大前提の準備としてユーザーAとユーザーBの変数を定義しておく
    let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }
    let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }

    before do
      # ユーザーAを作成しておく（letで共通化するため個別作成は不要となりコメントアウト）
      # user_a = FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com')
      # ↑のように属性を指定し任意の値を入れることもできる
      # ↓のように記述するとuser_aの属性は..factories/users.rbに記述された属性が入る
      # user_a = FactoryBot.create(:user)

      # 作成者がユーザーAであるタスクを作成しておく
      FactoryBot.create(:task, name: '最初のタスク', user: user_a)

      # 同階層のdescribe/contextで共通する処理はその一つ上階層のbeforeの中に記述することで処理の共通化が可能
      visit login_path
      fill_in 'メールアドレス', with: login_user.email
      fill_in 'パスワード', with: login_user.password
      click_button 'ログインする'
    end

    context 'ユーザーAがログインしている時' do
      # 一つ上の階層のbeforeの中に共通化したため↓コメントアウト
      # before do
      #   # ログイン画面にアクセスする
      #   # 「visit [URL]」で特定のURLにアクセスする
      #   visit login_path
      #   # メールアドレスを入力する
      #   # <label>のname属性を指定することでそのlabelと結び付いたテキストフィールドに値を入力する
      #   fill_in 'メールアドレス', with: 'a@example.com'
      #   # パスワードを入力する
      #   fill_in 'パスワード', with: 'password'
      #   # 「ログインする」ボタンをおす
      #   click_button 'ログインする'
      # end

      let(:login_user) { user_a }

      it 'ユーザーAが作成したタスクが表示される' do
        # 作成済みのタスクの名称が画面上に表示されていることを確認
        expect(page).to have_content '最初のタスク' # 「最初のタスク」という内容を画面に期待する的な
      end
    end

    context 'ユーザーBがログインしている時' do
      # before do
      #   # ユーザーBを作成しておく（letで共通化するため個別作成は不要となりコメントアウト）
      #   # FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com')
      #   # ユーザーBでログインする（一つ上の階層のbeforeの中に共通化したため↓コメントアウト）
      #   # visit login_path
      #   # fill_in 'メールアドレス', with: 'b@example.com'
      #   # fill_in 'パスワード', with: 'password'
      #   # click_button 'ログインする'
      # end

      let(:login_user) { user_b }

      it 'ユーザーAが作成したタスクが表示されない' do
        # ユーザーAが作成したタスクの名称が画面上に表示されていないことを確認
        expect(page).to have_no_content '最初のタスク'
        # expect(page).not_to have_content '最初のタスク' でも可
      end
    end
  end
end