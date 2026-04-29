import re

f = open(r'c:\Users\Usuario\Biux-app\Biux-app\lib\core\config\app_translations.dart', 'r', encoding='utf-8')
lines = f.readlines()
f.close()

new_keys = ['accessibility_appearance','achievements_count_label','achievements_unlocked_count','add_first_product_msg','alert_active','all_filter','allow_multiple_votes','adventure_category','app_theme_section','attendance_cancelled_msg','backup_chats_cloud','cannot_play_audio_msg','change_attendance_status','chat_settings_title','confirmed_tap_change','contacts_notified','copy_text_action','cycling_emergency','dark_mode_active','dark_mode_subtitle','device_preference_subtitle','distance_category','edit_message_action','emergency_button_label','error_loading_accidents','everyone_wont_see','explore_store_message','find_amazing_products','font_size','forward_message','getting_gps_signal','hold_to_send_sos','image_label_msg','interactions_section','last_seen_just_now','last_seen_minutes_ago','last_seen_unknown','light_mode_active','light_mode_subtitle','manage_blocked_list','marked_as_maybe','maybe_tap_change','no_achievements_in_category','no_likes_yet','no_reported_accidents','no_seller_permissions','not_going_anymore','not_sure_attendance','only_you_wont_see','options_section','participants_choose_multiple','payment_methods_available','pin_message','products_colon','put_products_here','quick_theme_change','react_label','recent_accidents','reduce_motion_label','reporting_user_name','ride_paused','ride_recording','rides_category','roads_clear','sample_text','send_audio_action','send_poll','severity_mild','share_location_action','social_category','specials_category','speed_category','star_message','stock_count_label','stock_issues','streak_category','syncing_achievements_msg','text_copied','text_size_label','time_days_ago','time_hours_ago','time_minutes_ago','time_months_ago','time_now','time_years_ago','unlocked_count_label','unpin_message','unstar_message','view_all_on_map','voice_message_label','your_content','your_shared_posts']

# Check in ES section (first ~4238 lines, before our additions)
es_section = ''.join(lines[21:4237])
already_existed = []
for k in new_keys:
    search = "'" + k + "':"
    if search in es_section:
        already_existed.append(k)

print('Keys that already existed (causing duplicates):')
for k in already_existed:
    print(f'  {k}')
print(f'\nTotal: {len(already_existed)}')
