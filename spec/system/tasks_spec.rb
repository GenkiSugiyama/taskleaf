require 'rails_helper'

# letを使って変数（のようなもの）に値を代入する
# let(定義名) {定義の内容}
# letで定義したものはその外側でも内側でも使用することができる
# letは呼び出されて初めて実行されるが、呼び出されなければ実行されない
# 呼び出しはしないが、定義内容を実行したい場合は「let!」を使用する

describe 'タスク管理機能', type: :system do

  # 大前提の準備としてユーザーAとユーザーBの変数を定義しておく
  let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }
  let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }
  # 詳細画面表示テストでしか呼び出ししていないが、一覧表示テストでも必要なため「let!」で定義している
  let!(:task_a) { FactoryBot.create(:task, name: '最初のタスク', user: user_a) }

  before do
    visit login_path
    fill_in 'メールアドレス', with: login_user.email
    fill_in 'パスワード', with: login_user.password
    click_button 'ログインする'
  end

  # it内の動作を共通化するために「shared_examples」を使用する
  shared_examples_for 'ユーザーAが作成したタスクが表示される' do
    it { expect(page).to have_content '最初のタスク' }
  end

  describe ('一覧表示機能') do

    context 'ユーザーAがログインしている時' do

      let(:login_user) { user_a }

      # 共通化されたitをshared_exampleを利用する形に書き換える
      it_behaves_like 'ユーザーAが作成したタスクが表示される'
    end

    context 'ユーザーBがログインしている時' do

      let(:login_user) { user_b }

      it 'ユーザーAが作成したタスクが表示されない' do
        # ユーザーAが作成したタスクの名称が画面上に表示されていないことを確認
        expect(page).to have_no_content '最初のタスク'
        # expect(page).not_to have_content '最初のタスク' でも可
      end
    end
  end

  describe '詳細表示機能' do
    context 'ユーザーAがログインしている時' do
      let(:login_user) { user_a }

      before do
        visit task_path(task_a)
      end

      # 共通化されたitをshared_exampleを利用する形に書き換える
      it_behaves_like 'ユーザーAが作成したタスクが表示される'
    end
  end

  describe '新規作成機能' do
    let(:login_user) { user_a }
    # 同じ処理内に複数回同じ名前のletを定義した場合はより下の階層に定義されたletが使用される（letの上書き）
    let(:task_name) { '新規作成のテストを書く' }

    before do
      visit new_task_path
      fill_in '名称', with: task_name
      click_button '登録する'
    end

    context '新規作成画面で名称を入力した時' do

      it '正常に登録される' do
        # have_selectorを使うとhtml内の要素をセレクタで指定できる
        expect(page).to have_selector '.alert-success', text: '新規作成のテストを書く'
      end
    end

    context '新規作成画面で名称を入力しなかった時' do
      let(:task_name) { '' } #describe直下にtask_nameのletが定義されているが、名称を入力しなかったときのテスト実行時のtask_nameはこちらに上書きされる

      it 'エラーとなる' do
        # withinで指定した要素の中のみで期待した要素が存在するかをチェックする
        within '#error_explanation' do
          expect(page).to have_content '名称を入力してください'
        end
      end
    end
  end

end