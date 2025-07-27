'use client'

import React, { useState } from 'react'

interface MapViewProps {
  activeTab: string
  onCardSelect: (cardId: string) => void
}

export default function MapView({ activeTab, onCardSelect }: MapViewProps) {
  const [selectedHeatmap, setSelectedHeatmap] = useState<'risk' | 'density' | 'timeline'>('risk')

  // モックデータ
  const mapCards = [
    { id: '1', x: 25, y: 35, risk: 0.87, type: 'pest', title: 'カメムシ大量発生' },
    { id: '2', x: 65, y: 45, risk: 0.72, type: 'disease', title: '灰色かび病の兆候' },
    { id: '3', x: 40, y: 60, risk: 0.65, type: 'environment', title: '異常高湿度継続' },
    { id: '4', x: 75, y: 25, risk: 0.45, type: 'pest', title: 'アブラムシ散発' },
    { id: '5', x: 20, y: 70, risk: 0.58, type: 'disease', title: 'うどんこ病初期症状' },
  ]

  const filteredCards = mapCards.filter(card => {
    if (activeTab === 'archive') return false // アーカイブは地図に表示しない
    return card.type === activeTab
  })

  const getPointColor = (risk: number) => {
    if (risk >= 0.6) return 'bg-risk-alert border-red-600'
    if (risk >= 0.4) return 'bg-risk-watch border-yellow-600'
    return 'bg-risk-ok border-green-600'
  }

  const getPointSize = (risk: number) => {
    if (risk >= 0.6) return 'w-6 h-6'
    if (risk >= 0.4) return 'w-5 h-5'
    return 'w-4 h-4'
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'pest': return '🐛'
      case 'disease': return '🍂'
      case 'environment': return '🌦️'
      default: return '📍'
    }
  }

  const getHeatmapOverlay = () => {
    switch (selectedHeatmap) {
      case 'risk':
        return (
          <div className="absolute inset-0 pointer-events-none">
            {/* リスクヒートマップのグラデーション */}
            <div 
              className="absolute rounded-full bg-red-500 opacity-20"
              style={{
                left: '20%',
                top: '30%',
                width: '30%',
                height: '20%',
                filter: 'blur(20px)'
              }}
            />
            <div 
              className="absolute rounded-full bg-yellow-500 opacity-15"
              style={{
                left: '60%',
                top: '40%',
                width: '25%',
                height: '15%',
                filter: 'blur(15px)'
              }}
            />
          </div>
        )
      case 'density':
        return (
          <div className="absolute inset-0 pointer-events-none">
            {/* 密度ヒートマップ */}
            <div 
              className="absolute rounded-full bg-blue-500 opacity-20"
              style={{
                left: '15%',
                top: '25%',
                width: '40%',
                height: '30%',
                filter: 'blur(25px)'
              }}
            />
          </div>
        )
      case 'timeline':
        return (
          <div className="absolute inset-0 pointer-events-none">
            {/* 時系列ヒートマップ */}
            <div 
              className="absolute rounded-full bg-purple-500 opacity-15"
              style={{
                left: '30%',
                top: '20%',
                width: '50%',
                height: '40%',
                filter: 'blur(30px)'
              }}
            />
          </div>
        )
      default:
        return null
    }
  }

  return (
    <div className="space-y-4">
      {/* ヒートマップ切り替え */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-800">🗺️ マップビュー</h3>
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-600">表示:</span>
          <select
            value={selectedHeatmap}
            onChange={(e) => setSelectedHeatmap(e.target.value as 'risk' | 'density' | 'timeline')}
            className="text-sm border border-gray-300 rounded px-2 py-1"
          >
            <option value="risk">リスクヒートマップ</option>
            <option value="density">発生密度</option>
            <option value="timeline">時系列</option>
          </select>
        </div>
      </div>

      {/* メインマップ */}
      <div className="relative bg-green-50 rounded-lg h-96 border border-gray-200 overflow-hidden">
        {/* 農地背景グリッド */}
        <div className="absolute inset-0 bg-gradient-to-b from-green-100 to-green-200">
          <div className="grid grid-cols-8 grid-rows-6 h-full opacity-30">
            {Array.from({ length: 48 }).map((_, i) => (
              <div key={i} className="border border-green-300"></div>
            ))}
          </div>
        </div>

        {/* ヒートマップオーバーレイ */}
        {getHeatmapOverlay()}

        {/* カードポイント */}
        {filteredCards.map((card) => (
          <div
            key={card.id}
            className={`
              absolute rounded-full border-2 cursor-pointer
              transform -translate-x-1/2 -translate-y-1/2
              hover:scale-125 transition-all duration-200
              flex items-center justify-center text-xs
              ${getPointColor(card.risk)} ${getPointSize(card.risk)}
            `}
            style={{
              left: `${card.x}%`,
              top: `${card.y}%`,
            }}
            onClick={() => onCardSelect(card.id)}
            title={`${card.title} (${(card.risk * 100).toFixed(0)}%)`}
          >
            <span className="text-white text-xs">
              {getTypeIcon(card.type)}
            </span>
            
            {/* ツールチップ */}
            <div className="absolute -top-12 left-1/2 transform -translate-x-1/2 bg-black text-white text-xs px-2 py-1 rounded opacity-0 hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
              {card.title}
              <br />
              Risk: {(card.risk * 100).toFixed(0)}%
            </div>
          </div>
        ))}

        {/* 座標系 */}
        <div className="absolute bottom-2 left-2 bg-white bg-opacity-90 px-2 py-1 rounded text-xs text-gray-600">
          Grid: 8×6 | Scale: 1:1000
        </div>

        {/* コンパス */}
        <div className="absolute top-2 right-2 bg-white bg-opacity-90 p-2 rounded">
          <div className="text-xs text-center">
            <div className="font-bold">N</div>
            <div className="text-gray-500">↑</div>
          </div>
        </div>
      </div>

      {/* 凡例 */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <h4 className="text-sm font-semibold text-gray-700 mb-3">凡例</h4>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* リスクレベル */}
          <div>
            <h5 className="text-xs font-semibold text-gray-600 mb-2">リスクレベル</h5>
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-xs">
                <div className="w-4 h-4 rounded-full bg-risk-alert border border-red-600"></div>
                <span>高リスク (≥60%)</span>
              </div>
              <div className="flex items-center gap-2 text-xs">
                <div className="w-4 h-4 rounded-full bg-risk-watch border border-yellow-600"></div>
                <span>中リスク (40-60%)</span>
              </div>
              <div className="flex items-center gap-2 text-xs">
                <div className="w-4 h-4 rounded-full bg-risk-ok border border-green-600"></div>
                <span>低リスク (&lt;40%)</span>
              </div>
            </div>
          </div>

          {/* カテゴリ */}
          <div>
            <h5 className="text-xs font-semibold text-gray-600 mb-2">カテゴリ</h5>
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-xs">
                <span>🐛</span>
                <span>害虫</span>
              </div>
              <div className="flex items-center gap-2 text-xs">
                <span>🍂</span>
                <span>病気</span>
              </div>
              <div className="flex items-center gap-2 text-xs">
                <span>🌦️</span>
                <span>環境</span>
              </div>
            </div>
          </div>
        </div>

        {/* ヒートマップ説明 */}
        <div className="mt-3 pt-3 border-t border-gray-200">
          <div className="text-xs text-gray-600">
            {selectedHeatmap === 'risk' && (
              <p><strong>リスクヒートマップ:</strong> 高リスク要因の集中度を色で表示</p>
            )}
            {selectedHeatmap === 'density' && (
              <p><strong>発生密度:</strong> 問題の発生密度を濃淡で表示</p>
            )}
            {selectedHeatmap === 'timeline' && (
              <p><strong>時系列:</strong> 最近の活動状況を時間軸で表示</p>
            )}
          </div>
        </div>
      </div>

      {/* 統計情報 */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-risk-alert">{filteredCards.filter(c => c.risk >= 0.6).length}</div>
          <div className="text-xs text-gray-600">高リスク</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-risk-watch">{filteredCards.filter(c => c.risk >= 0.4 && c.risk < 0.6).length}</div>
          <div className="text-xs text-gray-600">中リスク</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-3 text-center">
          <div className="text-lg font-bold text-risk-ok">{filteredCards.filter(c => c.risk < 0.4).length}</div>
          <div className="text-xs text-gray-600">低リスク</div>
        </div>
      </div>
    </div>
  )
}