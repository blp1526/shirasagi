# "Post" class for BBS. It represents "topic" models.
class Gws::Qna::Topic
  include Gws::Referenceable
  include Gws::Qna::Postable
  include Gws::Addon::Contributor
  include SS::Addon::Markdown
  include Gws::Addon::File
  include Gws::Qna::DescendantsFileInfo
  include Gws::Addon::Qna::Category
  include Gws::Addon::Release
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  include Gws::Addon::History
  include Gws::Qna::BrowsingState

  readable_setting_include_custom_groups

  field :question_state, type: String, default: 'open'

  permit_params :question_state

  validates :question_state, inclusion: { in: %w(open resolved) }
  validates :category_ids, presence: true
  after_validation :set_descendants_updated_with_released, if: -> { released.present? && released_changed? }

  # indexing to elasticsearch via companion object
  around_save ::Gws::Elasticsearch::Indexer::QnaTopicJob.callback
  around_destroy ::Gws::Elasticsearch::Indexer::QnaTopicJob.callback

  scope :custom_order, ->(key) {
    if key.start_with?('created_')
      all.order_by(created: key.end_with?('_asc') ? 1 : -1)
    elsif key.start_with?('updated_')
      all.order_by(descendants_updated: key.end_with?('_asc') ? 1 : -1)
    else
      all
    end
  }

  def updated?
    created.to_i != updated.to_i || created.to_i != descendants_updated.to_i
  end

  def subscribed_users
    return Gws::User.none if new_record?
    return Gws::User.none if categories.blank?

    conds = []
    conds << { id: { '$in' => categories.pluck(:subscribed_member_ids).flatten } }
    conds << { group_ids: { '$in' => categories.pluck(:subscribed_group_ids).flatten } }

    if Gws::Qna::Category.subscription_setting_included_custom_groups?
      custom_gropus = Gws::CustomGroup.in(id: categories.pluck(:subscribed_custom_group_ids))
      conds << { id: { '$in' => custom_gropus.pluck(:member_ids).flatten } }
    end

    Gws::User.where('$and' => [ { '$or' => conds } ])
  end

  def sort_options
    %w(updated_desc updated_asc created_desc created_asc).map { |k| [I18n.t("ss.options.sort.#{k}"), k] }
  end

  def resolved?
    question_state == 'resolved'
  end

  def question_state_options
    %w(open resolved).map { |k| [I18n.t("gws/qna.options.question_state.#{k}"), k] }
  end

  private

  def set_descendants_updated_with_released
    if descendants_updated.present?
      self.descendants_updated = released if descendants_updated < released
    else
      self.descendants_updated = released
    end
  end
end
