FactoryBot define do
  factory :task do
    name {'テストを書く'}
    description {'RSpec & Capybara & FactoryBotを準備する'}
    user #spec/factories/users.rbで定義した:userファクトリをTaskモデルに定義されたuserの生成に利用する
  end
end