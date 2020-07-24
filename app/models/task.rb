class Task < ApplicationRecord
  # 検証前コールバックを追加する
  # before_validation :set_nameless_name

  validates :name, presence: true
  validates :name, length: {maximum: 30}

  # 自作したい検証メソッドをvalidateというクラスメソッドに渡し、
  # このメソッドを検証用に使用するということを宣言する
  validate :validate_name_not_including_comma

  belongs_to :user

  # scopeメソッドでよく利用するデータの絞り込み条件を任意の名前で利用することができる
  # 以下は作成日時の新しい順に並べるための絞り込み条件を「recent」という名前のscopeとして利用できる
  scope :recent, -> { order(created_at: :desc) }

  # 画像ファイルを添付可能にするための処理
  # has_one_attachedで1つのタスクに1つの画像を紐付ける&紐付け多画像をTaskモデルからimageと呼ぶことを指定
  has_one_attached :image

  # ransackで検索して良いカラムの範囲を制限する
  # rancackの制限はStorngParametersを使っても同じような効果を得られるが
  # 下記のようにransackable_attributesなどで制御するやり方が一般的

  def self.ransackable_attributes(auth_object = nil)
    #ransackable_attributesを上書きして検索対象として許可するカラムを指定する
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    # ransackable_associationsにからの配列を返すことで関連テーブルを検索対象から外す
    []
  end

  # タスクデータをcsv出力するための処理を追加
  # csvデータにどの属性をどの順番で出力するかを設定&それをcsv_attributesというメソッドで得られるように定義
  def self.csv_attributes
    ["name", "description", "created_at", "updated_at"]
  end
  def self.generate_csv
    CSV.generate(headers: true) do |csv| # CSV.generateでCSVデータの文字列を生成
      csv << csv_attributes # CSVの1行目をヘッダとして出力（属性名を見出しとしている）
      all.each do |task|
        csv << csv_attributes.map{ |attr| task.send(attr) }
      end
    end
  end

  # csvインポート用の処理を実装
  def self.import(file)
    # foreachでファイルを1行ずつ読み込み、headers: trueの指定で1行目はヘッダーとして無視
    CSV.foreach(file.path, headers: true) do |row|
      #ファイルの1行ごとにTaskインスタンスを生成
      task = new
      # Taskインスタンスの各属性に1行ごとの属性値を入れていく
      # row→csvデータの1行内のデータ
      # row.to_hashで「属性1の値, 属性2の値・・」となっているデータを
      # 「{ 属性1のヘッダ名 ⇒ 属性1の値, 属性2のヘッダ名 ⇒ 属性2の値 }」のようなハッシュ値に変換している
      # さらにハッシュ値にslice(引数)を使って引数に指定しているキーに対応するデータのみを
      # csvから取り出して入力に使うようにしている
      task.attributes = row.to_hash.slice("name", "description", "created_at", "updated_at")
      task.save!
    end
  end

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
