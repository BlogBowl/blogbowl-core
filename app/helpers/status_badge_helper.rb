module StatusBadgeHelper
  def email_status_badge(status)
    badge_classes = {
      'draft' => 'bg-yellow-200 text-yellow-800 border border-yellow-500',
      'scheduled' => 'bg-green-200 text-green-800 border-green-500',
      'sent' => 'bg-gray-100 text-gray-800 border-gray-500'
    }

    default_classes = 'bg-gray-100 text-gray-800'

    badge_classes[status.to_s.downcase] || default_classes
  end

  def subscriber_status_badge(status)
    badge_classes = {
      'pending' => 'bg-yellow-200 text-yellow-800 border-yellow-500',
      'active' => 'bg-green-200 text-green-800 border-green-500',
      'suppressed' => 'bg-red-200 text-red-800 border-gray-500'
    }

    default_classes = 'bg-gray-100 text-gray-800'

    badge_classes[status.to_s.downcase] || default_classes
  end
end
