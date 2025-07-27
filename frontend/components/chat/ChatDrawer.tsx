'use client'

import React, { useState, useRef, useEffect } from 'react'

interface ChatMessage {
  id: string
  type: 'user' | 'ai'
  content: string
  timestamp: Date
  attachments?: Array<{
    type: 'card' | 'location' | 'image'
    data: any
  }>
}

export default function ChatDrawer() {
  const [isOpen, setIsOpen] = useState(false)
  const [isMinimized, setIsMinimized] = useState(false)
  const [message, setMessage] = useState('')
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: '1',
      type: 'ai',
      content: 'こんにちは！農業AIアシスタントです。何かお手伝いできることはありますか？',
      timestamp: new Date(Date.now() - 10 * 60 * 1000)
    },
    {
      id: '2',
      type: 'user',
      content: '東エリアの害虫状況を教えて',
      timestamp: new Date(Date.now() - 8 * 60 * 1000)
    },
    {
      id: '3',
      type: 'ai',
      content: '東エリアでは現在カメムシの発生が確認されています。リスクスコア0.87の高リスク状態です。以下のカードで詳細をご確認ください。',
      timestamp: new Date(Date.now() - 7 * 60 * 1000),
      attachments: [
        {
          type: 'card',
          data: { id: 'card_015', title: 'カメムシ大量発生', riskScore: 0.87 }
        }
      ]
    }
  ])

  const messagesEndRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const handleSendMessage = () => {
    if (!message.trim()) return

    const newMessage: ChatMessage = {
      id: `msg_${Date.now()}`,
      type: 'user',
      content: message,
      timestamp: new Date()
    }

    setMessages(prev => [...prev, newMessage])
    setMessage('')

    // AI応答をシミュレート
    setTimeout(() => {
      const aiResponse: ChatMessage = {
        id: `ai_${Date.now()}`,
        type: 'ai',
        content: generateAIResponse(message),
        timestamp: new Date()
      }
      setMessages(prev => [...prev, aiResponse])
    }, 1500)
  }

  const generateAIResponse = (userMessage: string): string => {
    const responses = [
      'ご質問ありがとうございます。データを確認しています...',
      'その件について、最新の情報をお調べします。',
      'リスク分析結果をもとに推奨アクションをご提案します。',
      '現在の状況を踏まえた対策をご提案いたします。'
    ]
    return responses[Math.floor(Math.random() * responses.length)]
  }

  const handleQuickInsert = (type: 'card' | 'location') => {
    if (type === 'card') {
      setMessage(prev => prev + ' [カード: card_015を参照]')
    } else if (type === 'location') {
      setMessage(prev => prev + ' [位置: 東エリア B-3]')
    }
    inputRef.current?.focus()
  }

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('ja-JP', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })
  }

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full shadow-lg hover:bg-blue-700 transition-all transform hover:scale-105 z-50"
      >
        💬
      </button>
    )
  }

  return (
    <div className={`
      fixed bottom-6 right-6 w-96 bg-white rounded-xl shadow-2xl border border-gray-200 z-50
      transition-all duration-300 ease-in-out
      ${isMinimized ? 'h-16' : 'h-[32rem]'}
    `}>
      {/* ヘッダー */}
      <div className="flex items-center justify-between p-4 border-b border-gray-200 bg-blue-50 rounded-t-xl">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-bold">
            AI
          </div>
          <div>
            <h3 className="font-semibold text-gray-800">農業AIアシスタント</h3>
            <div className="text-xs text-green-600 flex items-center gap-1">
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              オンライン
            </div>
          </div>
        </div>
        
        <div className="flex items-center gap-1">
          <button
            onClick={() => setIsMinimized(!isMinimized)}
            className="text-gray-400 hover:text-gray-600 p-1"
          >
            {isMinimized ? '⬆️' : '⬇️'}
          </button>
          <button
            onClick={() => setIsOpen(false)}
            className="text-gray-400 hover:text-gray-600 p-1"
          >
            ✕
          </button>
        </div>
      </div>

      {!isMinimized && (
        <>
          {/* メッセージエリア */}
          <div className="flex-1 p-4 h-80 overflow-y-auto">
            <div className="space-y-4">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex ${msg.type === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div className={`max-w-[80%] ${msg.type === 'user' ? 'order-2' : 'order-1'}`}>
                    <div
                      className={`
                        px-3 py-2 rounded-lg text-sm
                        ${msg.type === 'user'
                          ? 'bg-blue-600 text-white rounded-br-none'
                          : 'bg-gray-100 text-gray-800 rounded-bl-none'
                        }
                      `}
                    >
                      {msg.content}
                    </div>
                    
                    {/* 添付ファイル */}
                    {msg.attachments && (
                      <div className="mt-2 space-y-1">
                        {msg.attachments.map((attachment, index) => (
                          <div
                            key={index}
                            className="bg-white border border-gray-200 rounded p-2 text-xs"
                          >
                            {attachment.type === 'card' && (
                              <div className="flex items-center gap-2">
                                <span>🗂️</span>
                                <div>
                                  <div className="font-medium">{attachment.data.title}</div>
                                  <div className="text-gray-500">
                                    リスク: {(attachment.data.riskScore * 100).toFixed(0)}%
                                  </div>
                                </div>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}
                    
                    <div className={`text-xs text-gray-500 mt-1 ${msg.type === 'user' ? 'text-right' : 'text-left'}`}>
                      {formatTime(msg.timestamp)}
                    </div>
                  </div>
                  
                  {msg.type === 'ai' && (
                    <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-xs mr-2 mt-1">
                      🤖
                    </div>
                  )}
                </div>
              ))}
              <div ref={messagesEndRef} />
            </div>
          </div>

          {/* クイック挿入ボタン */}
          <div className="px-4 py-2 border-t border-gray-100">
            <div className="flex gap-2">
              <button
                onClick={() => handleQuickInsert('card')}
                className="text-xs bg-gray-100 hover:bg-gray-200 px-2 py-1 rounded transition-colors"
              >
                🗂️ カード引用
              </button>
              <button
                onClick={() => handleQuickInsert('location')}
                className="text-xs bg-gray-100 hover:bg-gray-200 px-2 py-1 rounded transition-colors"
              >
                📍 位置共有
              </button>
            </div>
          </div>

          {/* 入力エリア */}
          <div className="p-4 border-t border-gray-200">
            <div className="flex gap-2">
              <input
                ref={inputRef}
                type="text"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                placeholder="メッセージを入力..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
              />
              <button
                onClick={handleSendMessage}
                disabled={!message.trim()}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
              >
                📤
              </button>
            </div>
            
            <div className="text-xs text-gray-500 mt-2 text-center">
              AIが農業に関する質問にお答えします
            </div>
          </div>
        </>
      )}
    </div>
  )
}