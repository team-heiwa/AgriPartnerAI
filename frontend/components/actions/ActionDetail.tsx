'use client'

import React, { useState } from 'react'

interface ActionDetailProps {
  actionId: string | null
  onClose: () => void
  onVoiceMemo: () => void
}

export default function ActionDetail({ actionId, onClose, onVoiceMemo }: ActionDetailProps) {
  const [activeTab, setActiveTab] = useState<'details' | 'history' | 'related'>('details')

  if (!actionId) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-6 h-96 flex items-center justify-center">
        <div className="text-center text-gray-500">
          <span className="text-4xl block mb-2">👈</span>
          <p>アクションを選択してください</p>
        </div>
      </div>
    )
  }

  // モックデータ
  const actionData = {
    id: actionId,
    title: '換気30%減少',
    description: '灰色かび病対策として換気を30%減少させる。温室内の湿度を下げ、病原菌の繁殖を抑制します。',
    priority: 'high',
    status: 'todo',
    assignee: '田中農場長',
    dueDate: new Date('2024-01-16T10:00:00'),
    estimatedTime: 30,
    actualTime: undefined,
    tags: ['#換気制御', '#病気対策', '#灰色かび病'],
    relatedCard: 'card_014',
    createdBy: 'AI System',
    createdAt: new Date('2024-01-15T14:30:00'),
    updatedAt: new Date('2024-01-15T15:20:00'),
    checklist: [
      { id: '1', text: '現在の換気設定を確認', completed: false },
      { id: '2', text: '換気量を30%減少に調整', completed: false },
      { id: '3', text: '湿度センサーで効果を確認', completed: false },
      { id: '4', text: '24時間後に再評価', completed: false }
    ],
    history: [
      {
        id: '1',
        timestamp: new Date('2024-01-15T14:30:00'),
        action: 'created',
        user: 'AI System',
        description: 'アクションが自動生成されました'
      },
      {
        id: '2',
        timestamp: new Date('2024-01-15T15:20:00'),
        action: 'assigned',
        user: '管理システム',
        description: '田中農場長にアサインされました'
      }
    ],
    relatedActions: [
      { id: 'action_002', title: '葉面乾燥促進', status: 'todo' },
      { id: 'action_005', title: '湿度モニタリング強化', status: 'in_progress' }
    ],
    attachments: [
      { id: '1', name: '換気制御マニュアル.pdf', size: '2.3MB', type: 'pdf' },
      { id: '2', name: '現在の設定値.xlsx', size: '156KB', type: 'excel' }
    ]
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'text-risk-alert bg-red-50 border-risk-alert'
      case 'medium': return 'text-risk-watch bg-yellow-50 border-risk-watch'
      case 'low': return 'text-risk-ok bg-green-50 border-risk-ok'
      default: return 'text-gray-600 bg-gray-50 border-gray-300'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'todo': return 'bg-blue-100 text-blue-800'
      case 'in_progress': return 'bg-yellow-100 text-yellow-800'
      case 'review': return 'bg-purple-100 text-purple-800'
      case 'done': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
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

  const toggleChecklistItem = (itemId: string) => {
    // 実際の実装では状態更新ロジックが必要
    console.log('Toggle checklist item:', itemId)
  }

  return (
    <div className="bg-white rounded-lg border border-gray-200 h-full max-h-[600px] overflow-y-auto">
      {/* ヘッダー */}
      <div className="sticky top-0 bg-white border-b border-gray-200 p-4">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h2 className="text-lg font-semibold text-gray-800 mb-2">{actionData.title}</h2>
            <div className="flex items-center gap-2 mb-2">
              <span className={`text-xs font-bold px-2 py-1 rounded border ${getPriorityColor(actionData.priority)}`}>
                優先度: {actionData.priority.toUpperCase()}
              </span>
              <span className={`text-xs px-2 py-1 rounded ${getStatusColor(actionData.status)}`}>
                {actionData.status}
              </span>
            </div>
            <div className="text-sm text-gray-600">
              👤 {actionData.assignee} • ⏰ {formatDateTime(actionData.dueDate)}
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 ml-2"
          >
            ×
          </button>
        </div>

        {/* タブナビゲーション */}
        <div className="flex border-b border-gray-200 mt-4">
          {[
            { id: 'details', label: '詳細' },
            { id: 'history', label: '履歴' },
            { id: 'related', label: '関連' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as 'details' | 'history' | 'related')}
              className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
                activeTab === tab.id
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* 詳細タブ */}
        {activeTab === 'details' && (
          <div className="space-y-4">
            {/* 説明 */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">📝 説明</h3>
              <p className="text-sm text-gray-800 leading-relaxed">
                {actionData.description}
              </p>
            </div>

            {/* チェックリスト */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">✅ チェックリスト</h3>
              <div className="space-y-2">
                {actionData.checklist.map((item) => (
                  <label key={item.id} className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={item.completed}
                      onChange={() => toggleChecklistItem(item.id)}
                      className="rounded"
                    />
                    <span className={`text-sm ${item.completed ? 'line-through text-gray-500' : 'text-gray-800'}`}>
                      {item.text}
                    </span>
                  </label>
                ))}
              </div>
            </div>

            {/* タグ */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">🏷️ タグ</h3>
              <div className="flex flex-wrap gap-2">
                {actionData.tags.map((tag, index) => (
                  <span
                    key={index}
                    className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>

            {/* 時間追跡 */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">⏱️ 時間追跡</h3>
              <div className="text-sm text-gray-600">
                <div>予想時間: {actionData.estimatedTime}分</div>
                {actionData.actualTime && (
                  <div>実際の時間: {actionData.actualTime}分</div>
                )}
              </div>
            </div>

            {/* 添付ファイル */}
            {actionData.attachments.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">📎 添付ファイル</h3>
                <div className="space-y-2">
                  {actionData.attachments.map((file) => (
                    <div key={file.id} className="flex items-center gap-2 p-2 bg-gray-50 rounded">
                      <span className="text-sm">📄</span>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium text-gray-800 truncate">{file.name}</div>
                        <div className="text-xs text-gray-500">{file.size}</div>
                      </div>
                      <button className="text-xs text-blue-600 hover:text-blue-800">
                        ダウンロード
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* 履歴タブ */}
        {activeTab === 'history' && (
          <div className="space-y-3">
            {actionData.history.map((event) => (
              <div key={event.id} className="flex gap-3">
                <div className="flex-shrink-0 w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm text-gray-800">{event.description}</div>
                  <div className="text-xs text-gray-500">
                    {formatDateTime(event.timestamp)} • {event.user}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* 関連タブ */}
        {activeTab === 'related' && (
          <div className="space-y-4">
            {/* 関連カード */}
            {actionData.relatedCard && (
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">🔗 関連カード</h3>
                <div className="p-3 bg-gray-50 rounded border">
                  <div className="text-sm font-medium text-gray-800">{actionData.relatedCard}</div>
                  <div className="text-xs text-gray-500">灰色かび病の兆候</div>
                </div>
              </div>
            )}

            {/* 関連アクション */}
            <div>
              <h3 className="text-sm font-semibold text-gray-700 mb-2">⚡ 関連アクション</h3>
              <div className="space-y-2">
                {actionData.relatedActions.map((action) => (
                  <div key={action.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                    <span className="text-sm text-gray-800">{action.title}</span>
                    <span className={`text-xs px-2 py-1 rounded ${getStatusColor(action.status)}`}>
                      {action.status}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* アクションボタン */}
      <div className="sticky bottom-0 bg-white border-t border-gray-200 p-4">
        <div className="flex gap-2">
          <button
            onClick={onVoiceMemo}
            className="flex-1 bg-green-600 text-white px-3 py-2 rounded text-sm hover:bg-green-700 transition-colors"
          >
            🎤 音声メモ
          </button>
          <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700 transition-colors">
            📝 編集
          </button>
          <button className="px-3 py-2 border border-gray-300 rounded text-sm hover:bg-gray-50 transition-colors">
            ⋯
          </button>
        </div>
      </div>
    </div>
  )
}