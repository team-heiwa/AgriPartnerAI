'use client'

import React, { useState } from 'react'

interface Waypoint {
  id: string
  lat: number
  lng: number
  altitude: number
  action: 'photo' | 'video' | 'hover' | 'scan'
}

export default function ManualDroneControl() {
  const [isFlying, setIsFlying] = useState(false)
  const [waypoints, setWaypoints] = useState<Waypoint[]>([
    { id: '1', lat: 35.6762, lng: 139.6503, altitude: 50, action: 'photo' },
    { id: '2', lat: 35.6765, lng: 139.6510, altitude: 45, action: 'scan' },
    { id: '3', lat: 35.6760, lng: 139.6500, altitude: 55, action: 'video' },
  ])
  const [detectedObjects, setDetectedObjects] = useState([
    { id: '1', type: 'pest', confidence: 0.87, x: 45, y: 60 },
    { id: '2', type: 'disease', confidence: 0.73, x: 70, y: 40 },
  ])

  const handleTakeoff = () => {
    setIsFlying(true)
    console.log('ドローン離陸開始')
  }

  const handleLanding = () => {
    setIsFlying(false)
    console.log('ドローン着陸開始')
  }

  const handleCapture = () => {
    console.log('画像キャプチャ実行')
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {/* 左側: FPVライブ動画 */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-gray-800">📹 FPV Live Feed</h2>
        
        {/* ライブ動画エリア */}
        <div className="relative bg-black rounded-lg aspect-video overflow-hidden">
          {isFlying ? (
            <div className="w-full h-full bg-gradient-to-b from-blue-400 to-green-400 flex items-center justify-center">
              <div className="text-white text-center">
                <div className="text-4xl mb-2">🚁</div>
                <p>Live FPV Feed</p>
                <p className="text-sm opacity-75">高度: 50m | 速度: 5m/s</p>
              </div>
            </div>
          ) : (
            <div className="w-full h-full flex items-center justify-center text-white">
              <div className="text-center">
                <div className="text-6xl mb-4">🚁</div>
                <p>ドローンは待機中です</p>
              </div>
            </div>
          )}

          {/* AI検出オーバーレイ */}
          {isFlying && detectedObjects.map((obj) => (
            <div
              key={obj.id}
              className="absolute border-2 border-red-500 bg-red-500 bg-opacity-20"
              style={{
                left: `${obj.x}%`,
                top: `${obj.y}%`,
                width: '60px',
                height: '40px',
                transform: 'translate(-50%, -50%)'
              }}
            >
              <div className="absolute -top-6 left-0 bg-red-500 text-white text-xs px-2 py-1 rounded">
                {obj.type} {(obj.confidence * 100).toFixed(0)}%
              </div>
            </div>
          ))}

          {/* ステータスオーバーレイ */}
          {isFlying && (
            <div className="absolute top-4 left-4 bg-black bg-opacity-50 text-white px-3 py-2 rounded">
              <div className="text-sm space-y-1">
                <div>バッテリー: 85%</div>
                <div>GPS: 12衛星</div>
                <div>風速: 3.2m/s</div>
              </div>
            </div>
          )}
        </div>

        {/* コントロールボタン */}
        <div className="grid grid-cols-3 gap-3">
          <button
            onClick={handleTakeoff}
            disabled={isFlying}
            className="bg-green-600 text-white px-4 py-3 rounded-lg hover:bg-green-700 disabled:bg-gray-400 transition-colors"
          >
            🛫 離陸
          </button>
          
          <button
            onClick={handleCapture}
            disabled={!isFlying}
            className="bg-blue-600 text-white px-4 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 transition-colors"
          >
            📸 撮影
          </button>
          
          <button
            onClick={handleLanding}
            disabled={!isFlying}
            className="bg-red-600 text-white px-4 py-3 rounded-lg hover:bg-red-700 disabled:bg-gray-400 transition-colors"
          >
            🛬 着陸
          </button>
        </div>
      </div>

      {/* 右側: ミニマップとウェイポイント */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-gray-800">🗺️ Navigation</h2>
        
        {/* ミニマップ */}
        <div className="relative bg-green-50 rounded-lg h-64 overflow-hidden border border-gray-200">
          <div className="absolute inset-0 bg-gradient-to-b from-green-100 to-green-200">
            {/* 農地グリッド */}
            <div className="grid grid-cols-6 grid-rows-4 h-full opacity-30">
              {Array.from({ length: 24 }).map((_, i) => (
                <div key={i} className="border border-green-300"></div>
              ))}
            </div>
          </div>

          {/* ウェイポイント表示 */}
          {waypoints.map((waypoint, index) => (
            <div
              key={waypoint.id}
              className="absolute w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-xs font-bold border-2 border-white"
              style={{
                left: `${20 + index * 25}%`,
                top: `${30 + index * 15}%`,
                transform: 'translate(-50%, -50%)'
              }}
            >
              {index + 1}
            </div>
          ))}

          {/* ドローン位置 */}
          {isFlying && (
            <div
              className="absolute w-8 h-8 text-2xl transform -translate-x-1/2 -translate-y-1/2"
              style={{ left: '30%', top: '45%' }}
            >
              🚁
            </div>
          )}
        </div>

        {/* ウェイポイントリスト */}
        <div className="space-y-2">
          <h3 className="text-sm font-semibold text-gray-700">Waypoints</h3>
          <div className="space-y-2 max-h-40 overflow-y-auto">
            {waypoints.map((waypoint, index) => (
              <div
                key={waypoint.id}
                className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div className="flex items-center gap-3">
                  <span className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-xs font-bold">
                    {index + 1}
                  </span>
                  <div className="text-sm">
                    <div className="font-medium">
                      {waypoint.lat.toFixed(4)}, {waypoint.lng.toFixed(4)}
                    </div>
                    <div className="text-gray-500">
                      高度: {waypoint.altitude}m | {waypoint.action}
                    </div>
                  </div>
                </div>
                <button className="text-gray-400 hover:text-red-500">
                  🗑️
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* ミッション統計 */}
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-sm font-semibold text-gray-700 mb-3">Mission Stats</h3>
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-600">飛行時間:</span>
              <span className="font-semibold ml-1">
                {isFlying ? '00:05:32' : '00:00:00'}
              </span>
            </div>
            <div>
              <span className="text-gray-600">撮影数:</span>
              <span className="font-semibold ml-1">12枚</span>
            </div>
            <div>
              <span className="text-gray-600">検出数:</span>
              <span className="font-semibold ml-1">{detectedObjects.length}件</span>
            </div>
            <div>
              <span className="text-gray-600">カバー率:</span>
              <span className="font-semibold ml-1">45%</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}