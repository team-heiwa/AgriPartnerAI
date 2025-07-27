'use client'

import React, { useState } from 'react'

interface ScheduledRoute {
  id: string
  date: string
  time: string
  routeName: string
  estimatedDuration: number
  waypoints: number
  status: 'scheduled' | 'completed' | 'cancelled'
}

export default function RouteReservation() {
  const [selectedDate, setSelectedDate] = useState('')
  const [selectedTime, setSelectedTime] = useState('')
  const [routeName, setRouteName] = useState('')
  const [scheduledRoutes, setScheduledRoutes] = useState<ScheduledRoute[]>([
    {
      id: '1',
      date: '2024-01-15',
      time: '10:30',
      routeName: '北エリア定期巡回',
      estimatedDuration: 45,
      waypoints: 12,
      status: 'scheduled'
    },
    {
      id: '2',
      date: '2024-01-15',
      time: '14:00',
      routeName: '南エリア集中調査',
      estimatedDuration: 60,
      waypoints: 18,
      status: 'completed'
    }
  ])

  const handleScheduleRoute = () => {
    if (!selectedDate || !selectedTime || !routeName) return

    const newRoute: ScheduledRoute = {
      id: `route_${Date.now()}`,
      date: selectedDate,
      time: selectedTime,
      routeName,
      estimatedDuration: 45,
      waypoints: 8,
      status: 'scheduled'
    }

    setScheduledRoutes([...scheduledRoutes, newRoute])
    setSelectedDate('')
    setSelectedTime('')
    setRouteName('')
    console.log('新しいルートを予約:', newRoute)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'scheduled': return 'bg-blue-100 text-blue-800'
      case 'completed': return 'bg-green-100 text-green-800'
      case 'cancelled': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'scheduled': return '予約済み'
      case 'completed': return '完了'
      case 'cancelled': return 'キャンセル'
      default: return status
    }
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* 左側: 予約フォーム */}
      <div className="space-y-6">
        <h2 className="text-lg font-semibold text-gray-800">📅 新規ルート予約</h2>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              日付
            </label>
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              時刻
            </label>
            <input
              type="time"
              value={selectedTime}
              onChange={(e) => setSelectedTime(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              ルート名
            </label>
            <input
              type="text"
              value={routeName}
              onChange={(e) => setRouteName(e.target.value)}
              placeholder="例: 東エリア病害虫調査"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <button
            onClick={handleScheduleRoute}
            disabled={!selectedDate || !selectedTime || !routeName}
            className="w-full bg-blue-600 text-white px-4 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            📅 ルートを予約
          </button>
        </div>

        {/* ルートプレビュー */}
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-sm font-semibold text-gray-700 mb-3">🗺️ ルートプレビュー</h3>
          <div className="relative bg-green-50 rounded h-48 overflow-hidden border border-gray-200">
            <div className="absolute inset-0 bg-gradient-to-b from-green-100 to-green-200">
              {/* 農地表示 */}
              <div className="grid grid-cols-4 grid-rows-3 h-full opacity-30">
                {Array.from({ length: 12 }).map((_, i) => (
                  <div key={i} className="border border-green-300"></div>
                ))}
              </div>
            </div>

            {/* 予定ルート表示 */}
            <svg className="absolute inset-0 w-full h-full">
              <polyline
                points="20,40 60,30 80,60 40,80 20,70"
                stroke="#3B82F6"
                strokeWidth="3"
                fill="none"
                strokeDasharray="5,5"
              />
              {/* ウェイポイント */}
              {[{x: 20, y: 40}, {x: 60, y: 30}, {x: 80, y: 60}, {x: 40, y: 80}, {x: 20, y: 70}].map((point, i) => (
                <circle
                  key={i}
                  cx={`${point.x}%`}
                  cy={`${point.y}%`}
                  r="4"
                  fill="#3B82F6"
                  stroke="white"
                  strokeWidth="2"
                />
              ))}
            </svg>

            {/* ヒートマップオーバーレイ */}
            <div className="absolute top-2 right-2 bg-white bg-opacity-90 px-2 py-1 rounded text-xs">
              <div className="flex items-center gap-2">
                <div className="flex items-center gap-1">
                  <div className="w-2 h-2 bg-risk-alert rounded"></div>
                  <span>高リスク</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-2 h-2 bg-risk-watch rounded"></div>
                  <span>中リスク</span>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-3 text-sm text-gray-600">
            <div className="flex justify-between">
              <span>予想飛行時間:</span>
              <span className="font-semibold">45分</span>
            </div>
            <div className="flex justify-between">
              <span>ウェイポイント数:</span>
              <span className="font-semibold">8箇所</span>
            </div>
            <div className="flex justify-between">
              <span>対象面積:</span>
              <span className="font-semibold">2.5ha</span>
            </div>
          </div>
        </div>
      </div>

      {/* 右側: 予約済みルート一覧 */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-gray-800">📋 予約済みルート</h2>
        
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {scheduledRoutes.map((route) => (
            <div
              key={route.id}
              className="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
            >
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-semibold text-gray-800">{route.routeName}</h3>
                  <div className="text-sm text-gray-600">
                    {route.date} {route.time}
                  </div>
                </div>
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(route.status)}`}>
                  {getStatusLabel(route.status)}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-4 text-sm text-gray-600">
                <div>
                  <span>予想時間:</span>
                  <span className="font-semibold ml-1">{route.estimatedDuration}分</span>
                </div>
                <div>
                  <span>ポイント:</span>
                  <span className="font-semibold ml-1">{route.waypoints}箇所</span>
                </div>
              </div>

              {route.status === 'scheduled' && (
                <div className="flex gap-2 mt-3">
                  <button className="flex-1 bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700 transition-colors">
                    編集
                  </button>
                  <button className="flex-1 bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700 transition-colors">
                    キャンセル
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>

        {scheduledRoutes.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            <span className="text-4xl block mb-2">📅</span>
            <p>予約されたルートはありません</p>
          </div>
        )}

        {/* 今日のスケジュール */}
        <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
          <h3 className="text-sm font-semibold text-blue-800 mb-2">🗓️ 今日のスケジュール</h3>
          <div className="space-y-2">
            {scheduledRoutes
              .filter(route => route.date === new Date().toISOString().split('T')[0])
              .map(route => (
                <div key={route.id} className="flex items-center justify-between text-sm">
                  <span>{route.time} - {route.routeName}</span>
                  <span className={`px-2 py-1 rounded text-xs ${getStatusColor(route.status)}`}>
                    {getStatusLabel(route.status)}
                  </span>
                </div>
              ))}
            {scheduledRoutes.filter(route => route.date === new Date().toISOString().split('T')[0]).length === 0 && (
              <p className="text-blue-600 text-sm">今日の予定はありません</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}