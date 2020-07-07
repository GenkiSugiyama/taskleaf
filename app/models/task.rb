class Task < ApplicationRecord
  # 検証前コールバックを追加する
  before_validation :set_nameless_name

  validates :name, presence: true
  validates :name, length: {maximum: 30}

  # 自作したい検証メソッドをvalidateというクラスメソッドに渡し、
  # このメソッドを検証用に使用するということを宣言する
  validate :validate_name_not_including_comma

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
