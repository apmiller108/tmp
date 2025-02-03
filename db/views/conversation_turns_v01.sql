SELECT
  'text' AS turn_type,
  gtr.id,
  gtr.user_id,
  gtr.conversation_id,
  gtr.created_at,
  gtr.updated_at,
  gtr.text_id AS turn_id,
  gtr.prompt AS content,
  gtr.model,
  gtr.temperature,
  gtr.generate_text_preset_id,
  gtr.response,
  gtr.status,
  gtr.markdown_format
  FROM
    generate_text_requests gtr

 UNION ALL

SELECT
  'image' AS turn_type,
  gir.id,
  gir.user_id,
  gir.conversation_id,
  gir.created_at,
  gir.updated_at,
  gir.image_name AS turn_id,
  NULL AS content,
  NULL AS model,
  NULL AS temperature,
  NULL AS generate_text_preset_id,
  NULL AS response,
  NULL AS status,
  NULL AS markdown_format
  FROM
    generate_image_requests gir
