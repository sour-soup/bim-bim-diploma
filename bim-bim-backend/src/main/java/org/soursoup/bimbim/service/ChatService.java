package org.soursoup.bimbim.service;

import org.soursoup.bimbim.dto.request.UpdateImageRequest;
import org.soursoup.bimbim.entity.Chat;
import org.soursoup.bimbim.entity.Message;

import java.util.List;

public interface ChatService {
    List<Chat> getSentRequests(Long userId);

    List<Chat> getPendingRequests(Long userId);

    void acceptChatRequest(Long chatId, Long userId);

    List<Chat> getActiveChats(Long userId);

    Message sendMessage(Long chatId, Long userId, String content);

    List<Message> getMessages(Long chatId);

    Chat createChatRequest(Long fromUserId, Long toUserId);

    void declineChatRequest(Long chatId, Long userId);

    Message uploadImage(Long userId, Long chatId, UpdateImageRequest updateImageRequest);
}
