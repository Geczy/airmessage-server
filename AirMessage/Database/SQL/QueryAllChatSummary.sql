SELECT
    chat.guid AS "chat.guid",
    chat.display_name AS "chat.display_name",
    chat.service_name AS "chat.service_name",
    message.attributedBody AS "message.attributedBody",
    message.date AS "message.date",
    message.is_from_me AS "message.is_from_me",
    handle.id AS "handle.id",
    sub2.participant_list AS member_list,
    GROUP_CONCAT(attachment.mime_type) AS attachment_list
    %1$@ /* Extra fields, leading comma will be inserted */
FROM (
    SELECT
        sub1.*,
        GROUP_CONCAT(handle.id) AS participant_list
    FROM (
        SELECT
            chat.rowid AS chat_id,
            message.rowid AS message_id,
            MAX(message.date)
        FROM
            chat
        LEFT OUTER JOIN chat_message_join ON chat_message_join.chat_id = chat.rowid
    LEFT OUTER JOIN message ON chat_message_join.message_id = message.rowid
WHERE
    message.item_type = 0
GROUP BY
    chat.rowid) AS sub1
    LEFT OUTER JOIN chat_handle_join ON chat_handle_join.chat_id = sub1.chat_id
    LEFT OUTER JOIN handle ON chat_handle_join.handle_id = handle.rowid
GROUP BY
    sub1.chat_id) AS sub2
    LEFT OUTER JOIN chat ON chat.rowid = sub2.chat_id
    LEFT OUTER JOIN message ON message.rowid = sub2.message_id
    LEFT OUTER JOIN message_attachment_join ON message_attachment_join.message_id = sub2.message_id
    LEFT OUTER JOIN attachment ON message_attachment_join.attachment_id = attachment.rowid
    LEFT OUTER JOIN handle ON message.handle_id = handle.rowid
GROUP BY
    chat.rowid
ORDER BY
    message.date DESC
