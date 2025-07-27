'use client'

import React, { useState } from 'react'

interface Card {
  id: string
  type: 'pest' | 'disease' | 'environment'
  title: string
  description: string
  tags: string[]
  riskScore: number
  date: Date
  location: string
  images: string[]
  status: 'active' | 'resolved' | 'archived'
}

interface CardListProps {
  activeTab: string
  searchQuery: string
  onCardSelect: (cardId: string) => void
  selectedCard: string | null
}

export default function CardList({ activeTab, searchQuery, onCardSelect, selectedCard }: CardListProps) {
  const [sortBy, setSortBy] = useState<'date' | 'risk' | 'status'>('date')

  const mockCards: Card[] = [
    {
      id: '1',
      type: 'pest',
      title: 'カメムシ大量発生',
      description: '東エリアでカメムシの大量発生を確認。葉面への被害が拡大中。',
      tags: ['#カメムシ', '#緊急対応', '#東エリア'],
      riskScore: 0.87,
      date: new Date('2024-01-15T10:30:00'),
      location: '東エリア B-3',
      images: ['/placeholder1.jpg', '/placeholder2.jpg'],
      status: 'active'
    },
    {
      id: '2',
      type: 'disease',
      title: '灰色かび病の兆候',
      description: '湿度上昇により灰色かび病の初期症状を確認。予防措置が必要。',
      tags: ['#灰色かび病', '#予防処置', '#西エリア'],
      riskScore: 0.72,
      date: new Date('2024-01-14T14:20:00'),
      location: '西エリア A-1',
      images: ['/placeholder3.jpg'],
      status: 'active'
    },
    {
      id: '3',
      type: 'environment',
      title: '異常高湿度継続',
      description: '48時間以上湿度90%超えが継続。病害虫リスク上昇。',
      tags: ['#高湿度', '#要監視', '#全エリア'],
      riskScore: 0.65,
      date: new Date('2024-01-13T08:00:00'),
      location: '全エリア',
      images: [],
      status: 'active'
    },
    {
      id: '4',
      type: 'pest',
      title: 'アブラムシ散発',
      description: '南エリアでアブラムシの散発的発生。現状は軽微だが監視継続。',
      tags: ['#アブラムシ', '#監視継続', '#南エリア'],
      riskScore: 0.45,
      date: new Date('2024-01-12T16:45:00'),
      location: '南エリア C-2',
      images: ['/placeholder4.jpg'],
      status: 'resolved'
    }
  ]

  const filteredCards = mockCards.filter(card => {
    const matchesTab = activeTab === 'archive' ? card.status === 'archived' : card.type === activeTab
    const matchesSearch = searchQuery === '' || 
      card.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      card.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase()))
    
    return matchesTab && matchesSearch
  })

  const sortedCards = [...filteredCards].sort((a, b) => {
    switch (sortBy) {
      case 'date':
        return b.date.getTime() - a.date.getTime()
      case 'risk':
        return b.riskScore - a.riskScore
      case 'status':
        return a.status.localeCompare(b.status)
      default:
        return 0
    }
  })

  const getRiskColor = (score: number) => {
    if (score >= 0.6) return 'text-risk-alert bg-red-50 border-risk-alert'
    if (score >= 0.4) return 'text-risk-watch bg-yellow-50 border-risk-watch'
    return 'text-risk-ok bg-green-50 border-risk-ok'
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-blue-100 text-blue-800'
      case 'resolved': return 'bg-green-100 text-green-800'
      case 'archived': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'active': return 'アクティブ'
      case 'resolved': return '解決済み'
      case 'archived': return 'アーカイブ'
      default: return status
    }
  }

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('ja-JP', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="space-y-4">
      {/* ソート・フィルター */}
      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-600">
          {sortedCards.length}件のカードを表示
        </div>
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-600">並び順:</span>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as 'date' | 'risk' | 'status')}
            className="text-sm border border-gray-300 rounded px-2 py-1"
          >
            <option value="date">日付順</option>
            <option value="risk">リスク順</option>
            <option value="status">ステータス順</option>
          </select>
        </div>
      </div>

      {/* カードリスト */}
      <div className="space-y-3 max-h-96 overflow-y-auto">
        {sortedCards.map((card) => (
          <div
            key={card.id}
            onClick={() => onCardSelect(card.id)}
            className={`
              border rounded-lg p-4 cursor-pointer transition-all hover:shadow-md
              ${selectedCard === card.id 
                ? 'border-blue-500 bg-blue-50' 
                : 'border-gray-200 bg-white hover:border-gray-300'
              }
            `}
          >
            <div className="flex items-start justify-between mb-2">
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-gray-800 mb-1">{card.title}</h3>
                <p className="text-sm text-gray-600 line-clamp-2 mb-2">
                  {card.description}
                </p>
              </div>
              <div className="flex flex-col items-end gap-2 ml-4">
                <span className={`text-xs font-bold px-2 py-1 rounded border ${getRiskColor(card.riskScore)}`}>
                  {(card.riskScore * 100).toFixed(0)}%
                </span>
                <span className={`text-xs px-2 py-1 rounded ${getStatusColor(card.status)}`}>
                  {getStatusLabel(card.status)}
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between text-sm text-gray-500">
              <div className="flex items-center gap-4">
                <span>📍 {card.location}</span>
                <span>📅 {formatDate(card.date)}</span>
                {card.images.length > 0 && (
                  <span>📸 {card.images.length}</span>
                )}
              </div>
            </div>

            {/* タグ */}
            <div className="flex flex-wrap gap-1 mt-2">
              {card.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded"
                >
                  {tag}
                </span>
              ))}
              {card.tags.length > 3 && (
                <span className="text-xs text-gray-500">
                  +{card.tags.length - 3}
                </span>
              )}
            </div>
          </div>
        ))}
      </div>

      {sortedCards.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          <span className="text-4xl block mb-2">📝</span>
          <p>該当するカードがありません</p>
          {searchQuery && (
            <p className="text-sm mt-1">検索条件: "{searchQuery}"</p>
          )}
        </div>
      )}
    </div>
  )
}