'use client'

import React, { useState } from 'react'
import MainLayout from '../../components/MainLayout'
import CardList from '../../components/library/CardList'
import CardDetail from '../../components/library/CardDetail'
import MapView from '../../components/library/MapView'

export default function Library() {
  const [activeTab, setActiveTab] = useState('pest')
  const [selectedCard, setSelectedCard] = useState<string | null>(null)
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list')
  const [searchQuery, setSearchQuery] = useState('')

  const tabs = [
    { id: 'pest', label: '🐛 害虫', count: 24 },
    { id: 'disease', label: '🍂 病気', count: 18 },
    { id: 'environment', label: '🌦️ 環境', count: 12 },
    { id: 'archive', label: '📂 アーカイブ', count: 156 }
  ]

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-800">Library</h1>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <button
                onClick={() => setViewMode('list')}
                className={`p-2 rounded ${viewMode === 'list' ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-100'}`}
              >
                📋
              </button>
              <button
                onClick={() => setViewMode('map')}
                className={`p-2 rounded ${viewMode === 'map' ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-100'}`}
              >
                🗺️
              </button>
            </div>
          </div>
        </div>

        {/* タブバー */}
        <div className="bg-white rounded-lg shadow-md">
          <div className="flex border-b">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`
                  flex-1 px-6 py-4 text-center font-medium transition-colors
                  ${activeTab === tab.id
                    ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50'
                    : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
                  }
                `}
              >
                <div className="flex items-center justify-center gap-2">
                  <span>{tab.label}</span>
                  <span className="bg-gray-200 text-gray-700 text-xs px-2 py-1 rounded-full">
                    {tab.count}
                  </span>
                </div>
              </button>
            ))}
          </div>

          {/* 検索バー */}
          <div className="p-4 border-b">
            <div className="flex gap-4">
              <div className="flex-1">
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="カード、タグ、日付で検索..."
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                🔍 検索
              </button>
              <button className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
                🏷️ タグ
              </button>
            </div>
          </div>

          {/* メインコンテンツ */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-6">
            {/* 左ペイン: カードリスト/マップ */}
            <div className="lg:col-span-2">
              {viewMode === 'list' ? (
                <CardList
                  activeTab={activeTab}
                  searchQuery={searchQuery}
                  onCardSelect={setSelectedCard}
                  selectedCard={selectedCard}
                />
              ) : (
                <MapView
                  activeTab={activeTab}
                  onCardSelect={setSelectedCard}
                />
              )}
            </div>

            {/* 右ペイン: カード詳細 */}
            <div className="lg:col-span-1">
              <CardDetail
                cardId={selectedCard}
                onClose={() => setSelectedCard(null)}
              />
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}