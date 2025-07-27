'use client'

import React from 'react'

interface Alert {
  id: string
  timestamp: Date
  type: 'weather' | 'pest' | 'disease' | 'system'
  severity: 'high' | 'medium' | 'low'
  message: string
  icon: string
}

export default function AlertFeed() {
  const alerts: Alert[] = [
    {
      id: '1',
      timestamp: new Date(Date.now() - 5 * 60 * 1000),
      type: 'weather',
      severity: 'high',
      message: '湿度 92% 継続 → 灰色かび病注意',
      icon: '🌧️'
    },
    {
      id: '2',
      timestamp: new Date(Date.now() - 15 * 60 * 1000),
      type: 'pest',
      severity: 'medium',
      message: 'エリア B-3 でカメムシ活動増加',
      icon: '🐛'
    },
    {
      id: '3',
      timestamp: new Date(Date.now() - 45 * 60 * 1000),
      type: 'system',
      severity: 'low',
      message: 'ドローン #02 バッテリー残量 25%',
      icon: '🔋'
    },
    {
      id: '4',
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
      type: 'disease',
      severity: 'medium',
      message: '西エリアで葉面病斑パターン検出',
      icon: '🍂'
    }
  ]

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'high': return 'border-risk-alert bg-red-50 text-risk-alert'
      case 'medium': return 'border-risk-watch bg-yellow-50 text-risk-watch'
      case 'low': return 'border-risk-ok bg-green-50 text-risk-ok'
      default: return 'border-gray-300 bg-gray-50 text-gray-600'
    }
  }

  const formatTime = (date: Date) => {
    const now = new Date()
    const diff = Math.floor((now.getTime() - date.getTime()) / 1000 / 60)
    
    if (diff < 60) return `${diff}分前`
    const hours = Math.floor(diff / 60)
    if (hours < 24) return `${hours}時間前`
    const days = Math.floor(hours / 24)
    return `${days}日前`
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-4">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-800">アラートフィード</h2>
        <button className="text-sm text-blue-600 hover:text-blue-800">
          すべて表示
        </button>
      </div>
      
      <div className="space-y-3 max-h-80 overflow-y-auto">
        {alerts.map((alert) => (
          <div
            key={alert.id}
            className={`
              border-l-4 pl-3 py-2 rounded-r
              ${getSeverityColor(alert.severity)}
            `}
          >
            <div className="flex items-start gap-2">
              <span className="text-lg mt-0.5">{alert.icon}</span>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-800 leading-relaxed">
                  {alert.message}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {formatTime(alert.timestamp)}
                </p>
              </div>
              <button className="text-gray-400 hover:text-gray-600 text-sm">
                ×
              </button>
            </div>
          </div>
        ))}
      </div>
      
      {alerts.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          <span className="text-4xl mb-2 block">✅</span>
          <p>新しいアラートはありません</p>
        </div>
      )}
    </div>
  )
}