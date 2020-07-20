# Userデータを事前登録するためのファクトリの定義
FactoryBot.define do
  factory :user do
    name {'テストユーザー'}
    email {'test1@example.com'}
    password {'password'}
  end
end