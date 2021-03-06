module ApplicationHelper
  def target_progress_color(progress)
    progress = progress.to_i
    if progress > 90
      result = 'green'
    elsif progress < 90 && progress > 80
      result = 'orange'
    else
      result = 'red'
    end
    result
  end

  def days_left_color(days_left)
    days_left = days_left.to_i
    if days_left > 30
      result = 'green'
    elsif days_left < 30 && days_left > 10
      result = 'orange'
    else
      result = 'red'
    end
    result
  end

  def bootstrap_class_for(flash_type)
    logger.debug "flash_type is #{flash_type}"
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def label_for(event_state)
    result = ''
    case event_state
    when 'new'
      result = 'label label-primary'
    when 'withdrawn'
      result = 'label label-danger'
    when 'unconfirmed'
      result = 'label label-success'
    when 'confirmed'
      result = 'label label-success'
    when 'rejected'
      result = 'label label-warning'
    when 'canceled'
      result = 'label label-danger'
    end
    result
  end

  def icon_for_todo(bool)
    if bool
      return 'fa fa-check'
    else
      return 'fa fa-times'
    end
  end

  def class_for_todo(bool)
    if bool
      return 'list-group-item todolist-ok'
    else
      return 'list-group-item todolist-missing'
    end
  end

  def normalize_array_length(hashmap, length)
    hashmap.each do |_, value|
      if value.length < length
        value.fill(value[-1], value.length...length)
      end
    end
  end

  def active_nav_li(link)
    if current_page?(link)
      return 'active'
    else
      return ''
    end
  end

  def getdatetime(registration, field)
    if registration.send(field.to_sym).kind_of?(String)
      DateTime.parse(registration.send(field.to_sym)).strftime('%d %b %H:%M') if registration.send(field.to_sym)
    else
      registration.send(field.to_sym).strftime('%d %b %H:%M') if registration.send(field.to_sym)
    end
  end

  def getdate(var)
    if var.kind_of?(String)
      DateTime.parse(var).strftime('%a, %d %b')
    else
      var.strftime('%a, %d %b')
    end
  end

  def show_time(length)
    h = length / 60
    min = length - h * 60

    if h != 0
      if min != 0
      "#{h} h #{min} min"
      else
        "#{h} h"
      end
    else
      "#{min} min"
    end
  end

  def pre_registered(event)
    @conference.events.joins(:registrations).where('events.id = ?', event.id)
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association 'Add ' + association_name.to_s.singularize, form_builder, div_class, html_options.merge(class: 'assoc btn btn-success')
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association('Remove ' + association_name.to_s.singularize, form_builder, class: 'assoc btn btn-danger') + tag(:hr)
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render 'shared/dynamic_association', association_name: association_name, title: title, f: form_builder, hint: options[:hint]
  end

  # Same as redirect_to(:back) if there is a valid HTTP referer, otherwise redirect_to()
  def redirect_back_or_to(options = {}, response_status = {})
    if request.env['HTTP_REFERER']
      redirect_to(:back)
    else
      redirect_to(options, response_status)
    end
  end

  # TODO Output better html
  def format_comments(comment, padding = 0)
    result = ''
    result += "<div style='padding-left:#{padding}px'>"
    result += "<div class='well'>"
    result += "<b>#{comment.user.name}</b> <i>#{comment.created_at}</i><br><br>"
    result += comment.body
    result += "<br><div><a href='#' class='pull-right comment-reply-link'>Reply</a><br><br>"
    result += "<div class='comment-reply'>"
    result += "<form method='post' action='#{comment_admin_conference_event_path(@conference.short_title, comment.commentable_id)}'>"
    result += "<input type=hidden name=parent value='#{comment.id}'/>"
    result += "<input name='authenticity_token' type='hidden' value='#{form_authenticity_token}' />"
    result += "<textarea name='comment'></textarea>"
    result += "<button class='btn btn-primary pull-right' name='button' type='submit'>Add Reply</button>"
    result += '</form></div></div>'
    result += '</div>'
    #result += edit_admin_conference_event_path(@conference.short_title, @event)
    comment.children.each do |child|
      result += format_comments(child, 50)
      result += '</div>'
    end

    result
  end

  def event_types(conference)
    all = conference.event_types.map { |et | et.title.pluralize }
    first = all[0...-1]
    last = all[-1]
    ets = ''
    if all.length > 1
      ets << first.join(', ')
      ets << " and #{last}"
    else
      ets = all.join
    end
    return ets
  end

  def tracks(conference)
    all = conference.tracks.map {|t| t.name}
    first = all[0...-1]
    last = all[-1]
    ts = ''
    if all.length > 1
      ts << first.join(', ')
      ts << " and #{last}"
    else
      ts = all.join
    end
    return ts
  end

  # rubocop:disable Lint/EndAlignment
  def word_pluralize(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || singular.pluralize
    end

    "#{word}"
  end

  def markdown(text)
    options = {
      autolink: true,
      space_after_headers: true,
      no_intra_emphasis: true
    }
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    markdown.render(text).html_safe
  end

  def markdown_hint(text='')
    markdown("#{text} Please look at #{link_to '**Markdown Syntax**', 'https://daringfireball.net/projects/markdown/syntax', target: '_blank'} to format your text")
  end

  def omniauth_configured
    providers = []
    Devise.omniauth_providers.each do |provider|
      provider_key = "#{provider}_key"
      provider_secret = "#{provider}_secret"
      unless Rails.application.secrets.send(provider_key).blank? || Rails.application.secrets.send(provider_secret).blank?
        providers << provider
      end
    end
    return providers
  end

  # Receives a hash, generated from User model, function get_roles
  # Outputs the roles of a user, including the conferences for which the user has the roles
  # Eg. organizer(oSC13, oSC14), cfp(oSC12, oSC13)
  def show_roles(roles)
    roles.map { |x| x[0].titleize + ' ' + x[1] }.join ', '
  end

  def can_manage_volunteers(conference)
    if (current_user.has_role? :organizer, conference) || (current_user.has_role? :volunteer_coordinator, conference)
      true
    else
      false
    end
  end

  def sign_in_path
    if CONFIG['authentication']['ichain']['enabled']
      new_user_ichain_session_path
    else
      new_user_session_path
    end
  end

  def sign_up_path
    if CONFIG['authentication']['ichain']['enabled']
      new_user_ichain_registration_path
    else
      new_user_registration_path
    end
  end
end
