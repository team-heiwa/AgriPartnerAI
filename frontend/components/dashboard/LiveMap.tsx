'use client'

import React, { useState } from 'react'

interface MapPoint {
  id: string
  lat: number
  lng: number
  risk: number
  type: 'pest' | 'disease'
  title: string
}

export default function LiveMap() {
  const [mapPoints] = useState<MapPoint[]>([
    { id: '1', lat: 35.6762, lng: 139.6503, risk: 0.72, type: 'disease', title: '灰色かび病疑い' },
    { id: '2', lat: 35.6765, lng: 139.6510, risk: 0.66, type: 'pest', title: 'カメムシ発見' },
    { id: '3', lat: 35.6760, lng: 139.6500, risk: 0.45, type: 'pest', title: 'アブラムシ注意' },
    { id: '4', lat: 35.6758, lng: 139.6515, risk: 0.28, type: 'disease', title: '健康状態良好' },
  ])

  const getPointColor = (risk: number) => {
    if (risk >= 0.6) return 'bg-risk-alert'
    if (risk >= 0.4) return 'bg-risk-watch'
    return 'bg-risk-ok'
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-4">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-800">リアルタイムマップ</h2>
        <button className="text-sm text-blue-600 hover:text-blue-800">
          詳細表示
        </button>
      </div>
      
      {/* 簡易マップ表示 - 実際にはMapboxやGoogle Mapsを使用 */}
      <div className="relative bg-green-50 rounded-lg h-64 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-green-100 to-green-200">
          {/* 農地のグリッド表示 */}
          <div className="grid grid-cols-8 grid-rows-6 h-full opacity-30">
            {Array.from({ length: 48 }).map((_, i) => (
              <div key={i} className="border border-green-300"></div>
            ))}
          </div>
        </div>
        
        {/* リスクポイント */}
        {mapPoints.map((point) => (
          <div
            key={point.id}
            className={`
              absolute w-4 h-4 rounded-full ${getPointColor(point.risk)}
              border-2 border-white shadow-lg cursor-pointer
              transform -translate-x-1/2 -translate-y-1/2
              hover:scale-125 transition-transform
            `}
            style={{
              left: `${20 + Math.random() * 60}%`,
              top: `${20 + Math.random() * 60}%`,
            }}
            title={`${point.title} (${point.risk.toFixed(2)})`}
          >
            <div className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-black text-white text-xs px-2 py-1 rounded opacity-0 hover:opacity-100 transition-opacity whitespace-nowrap">
              {point.title}
            </div>
          </div>
        ))}
      </div>
      
      {/* 凡例 */}
      <div className="flex items-center justify-center gap-4 mt-3 text-sm">
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 rounded-full bg-risk-alert"></div>
          <span>高リスク (≥0.6)</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 rounded-full bg-risk-watch"></div>
          <span>中リスク (0.4-0.6)</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-3 h-3 rounded-full bg-risk-ok"></div>
          <span>低リスク (0.4)</span>
        </div>
      </div>
    </div>
  )
}