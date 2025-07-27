'use client'

import React, { useState } from 'react'

interface CardDetailProps {
  cardId: string | null
  onClose: () => void
}

export default function CardDetail({ cardId, onClose }: CardDetailProps) {
  const [activeImageIndex, setActiveImageIndex] = useState(0)

  if (!cardId) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-6 h-96 flex items-center justify-center">
        <div className="text-center text-gray-500">
          <span className="text-4xl block mb-2">👈</span>
          <p>カードを選択してください</p>
        </div>
      </div>
    )
  }

  // モックデータ（実際にはcardIdに基づいてデータを取得）
  const cardData = {
    id: cardId,
    title: 'カメムシ大量発生',
    type: 'pest',
    description: '東エリアでカメムシの大量発生を確認。葉面への被害が拡大中。早急な対策が必要です。',
    riskScore: 0.87,
    status: 'active',
    date: new Date('2024-01-15T10:30:00'),
    location: '東エリア B-3',
    coordinates: { lat: 35.6762, lng: 139.6503 },
    images: [
      'https://via.placeholder.com/400x300/10b981/ffffff?text=Image+1',
      'https://via.placeholder.com/400x300/f59e0b/ffffff?text=Image+2',
      'https://via.placeholder.com/400x300/ef4444/ffffff?text=Image+3'
    ],
    tags: ['#カメムシ', '#緊急対応', '#東エリア', '#害虫'],
    timeline: [
      {
        id: '1',
        date: new Date('2024-01-15T10:30:00'),
        type: 'detection',
        description: 'ドローン調査で初期発見',
        user: 'AI System'
      },
      {
        id: '2',
        date: new Date('2024-01-15T11:00:00'),
        type: 'confirmation',
        description: '現地確認で大量発生を確認',
        user: '田中農場長'
      },
      {
        id: '3',
        date: new Date('2024-01-15T11:30:00'),
        type: 'action',
        description: '薬剤散布の準備開始',
        user: '佐藤作業員'
      }
    ],
    relatedActions: ['防除スケジュール調整', '薬剤散布準備', '被害範囲調査']
  }

  const getRiskColor = (score: number) => {
    if (score >= 0.6) return 'text-risk-alert bg-red-50 border-risk-alert'
    if (score >= 0.4) return 'text-risk-watch bg-yellow-50 border-risk-watch'
    return 'text-risk-ok bg-green-50 border-risk-ok'
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'pest': return '🐛'
      case 'disease': return '🍂'
      case 'environment': return '🌦️'
      default: return '📝'
    }
  }

  const getActionIcon = (type: string) => {
    switch (type) {
      case 'detection': return '🔍'
      case 'confirmation': return '✅'
      case 'action': return '🚀'
      default: return '📝'
    }
  }

  const formatDateTime = (date: Date) => {
    return date.toLocaleString('ja-JP', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="bg-white rounded-lg border border-gray-200 h-full max-h-[600px] overflow-y-auto">
      {/* ヘッダー */}
      <div className="sticky top-0 bg-white border-b border-gray-200 p-4">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-xl">{getTypeIcon(cardData.type)}</span>
              <h2 className="text-lg font-semibold text-gray-800">{cardData.title}</h2>
              <span className={`text-xs font-bold px-2 py-1 rounded border ${getRiskColor(cardData.riskScore)}`}>
                {(cardData.riskScore * 100).toFixed(0)}%
              </span>
            </div>
            <div className="text-sm text-gray-600">
              📍 {cardData.location} • 📅 {formatDateTime(cardData.date)}
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 ml-2"
          >
            ×
          </button>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* 画像カルーセル */}
        {cardData.images.length > 0 && (
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">📸 画像</h3>
            <div className="space-y-2">
              <img
                src={cardData.images[activeImageIndex]}
                alt={`Image ${activeImageIndex + 1}`}
                className="w-full h-48 object-cover rounded-lg border border-gray-200"
              />
              {cardData.images.length > 1 && (
                <div className="flex gap-2 overflow-x-auto">
                  {cardData.images.map((image, index) => (
                    <img
                      key={index}
                      src={image}
                      alt={`Thumbnail ${index + 1}`}
                      onClick={() => setActiveImageIndex(index)}
                      className={`w-16 h-12 object-cover rounded cursor-pointer border-2 ${
                        activeImageIndex === index ? 'border-blue-500' : 'border-gray-200'
                      }`}
                    />
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* 説明 */}
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">📝 詳細</h3>
          <p className="text-sm text-gray-800 leading-relaxed">
            {cardData.description}
          </p>
        </div>

        {/* タグ */}
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">🏷️ タグ</h3>
          <div className="flex flex-wrap gap-2">
            {cardData.tags.map((tag, index) => (
              <span
                key={index}
                className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>

        {/* タイムライン */}
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">⏰ タイムライン</h3>
          <div className="space-y-3">
            {cardData.timeline.map((event) => (
              <div key={event.id} className="flex gap-3">
                <div className="flex-shrink-0 w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-xs">
                  {getActionIcon(event.type)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm text-gray-800">{event.description}</div>
                  <div className="text-xs text-gray-500">
                    {formatDateTime(event.date)} • {event.user}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* 関連アクション */}
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">⚡ 関連アクション</h3>
          <div className="space-y-2">
            {cardData.relatedActions.map((action, index) => (
              <button
                key={index}
                className="w-full text-left text-sm bg-gray-50 hover:bg-gray-100 p-2 rounded border border-gray-200 transition-colors"
              >
                🎯 {action}
              </button>
            ))}
          </div>
        </div>

        {/* アクションボタン */}
        <div className="flex gap-2 pt-4 border-t">
          <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700 transition-colors">
            📝 編集
          </button>
          <button className="flex-1 bg-green-600 text-white px-3 py-2 rounded text-sm hover:bg-green-700 transition-colors">
            ✅ 解決
          </button>
          <button className="px-3 py-2 border border-gray-300 rounded text-sm hover:bg-gray-50 transition-colors">
            📁
          </button>
        </div>
      </div>
    </div>
  )
}