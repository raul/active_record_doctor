class ActiveRecordDoctor::Tasks::MissingNonNullConstraintTest < Minitest::Test
  def test_presence_true_and_null_true
    Temping.create(:users, temporary: false) do
      validates :name, presence: true

      with_columns do |t|
        t.string :name, null: true
      end
    end

    assert_equal({ 'users' => ['name'] }, run_task)
  end

  def test_association_presence_true_and_null_true
    Temping.create(:companies, temporary: false)
    Temping.create(:users, temporary: false) do
      belongs_to :company, required: true

      with_columns do |t|
        t.references :company
      end
    end

    assert_equal({ 'users' => ['company_id'] }, run_task)
  end

  def test_presence_true_and_null_false
    Temping.create(:users, temporary: false) do
      validates :name, presence: true

      with_columns do |t|
        t.string :name, null: false
      end
    end

    assert_equal({}, run_task)
  end

  def test_presence_false_and_null_true
    Temping.create(:users, temporary: false) do
      # The age validator is a form of regression test against a bug that
      # caused false positives. In this test case, name is NOT validated
      # for presence so it does NOT need be marked non-NULL. However, the
      # bug would match the age presence validator with the NULL-able name
      # column which would result in a false positive error report.
      validates :age, presence: true
      validates :name, presence: false

      with_columns do |t|
        t.string :name, null: true
      end
    end

    assert_equal({}, run_task)
  end

  def test_presence_false_and_null_false
    Temping.create(:users, temporary: false) do
      validates :name, presence: false

      with_columns do |t|
        t.string :name, null: false
      end
    end

    assert_equal({}, run_task)
  end

  def test_presence_true_with_if
    Temping.create(:users, temporary: false) do
      validates :name, presence: true, if: -> { false }

      with_columns do |t|
        t.string :name, null: true
      end
    end

    assert_equal({}, run_task)
  end

  def test_presence_true_with_unless
    Temping.create(:users, temporary: false) do
      validates :name, presence: true, unless: -> { false }

      with_columns do |t|
        t.string :name, null: true
      end
    end

    assert_equal({}, run_task)
  end

  def test_presence_true_with_allow_nil
    Temping.create(:users, temporary: false) do
      validates :name, presence: true, allow_nil: true

      with_columns do |t|
        t.string :name, null: true
      end
    end

    assert_equal({}, run_task)
  end
end
