class Task < ApplicationRecord
  # 検証前コールバックを追加する
  before_validation :set_nameless_name

  validates :name, presence: true
  validates :name, length: {maximum: 30}

  # 自作したい検証メソッドをvalidateというクラスメソッドに渡し、
  # このメソッドを検証用に使用するということを宣言する
  validate :validate_name_not_including_comma

  belongs_to :user

  # scopeメソッドでよく利用するデータの絞り込み条件を任意の名前で利用することができる
  # 以下は作成日時の新しい順に並べるための絞り込み条件を「recent」という名前のscopeとして利用できる
  scope :recent, -> { order(created_at: :desc) }

  private

# 検証用のメソッドはモデルクラス内でしか使わない（外部からは呼び出されない）
  # 想定なのでprivate以下に記述する
  def validate_name_not_including_comma
    errors.add(:name, 'にカンマを含めることはできません') if name&.include?(',')
  end

  def set_nameless_name
    self.name = "名前なし" if name.blank?
  end
end
