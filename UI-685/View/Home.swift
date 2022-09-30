//
//  Home.swift
//  UI-685
//
//  Created by nyannyan0328 on 2022/09/30.
//

import SwiftUI

struct Home: View {
    @State var charactes : [Character] = []
    
    @GestureState var isDragging : Bool = false
    @State var offsetY : CGFloat = 0
    
    @State var currentAcitiveIndex : Int = 0
    @State var isDrag : Bool = false
    @State var startOffset : CGFloat = 0
    
    var body: some View {
        NavigationStack{
            
            ScrollViewReader { proxy in
                
                ScrollView(.vertical,showsIndicators: false){
                 
                    VStack(spacing:0){
                        
                        ForEach(charactes){character in
                            
                            
                            ContactView(character: character)
                                .id(character.index)
                            
                        }
                        
                        
                    }
                    .padding(.top,15)
                    .padding(.trailing,100)
                    
                    
                }
                .onChange(of: currentAcitiveIndex) { newValue in
                    if isDrag{
                        
                        withAnimation(.easeOut(duration: 0.15)){
                            
                            proxy.scrollTo(currentAcitiveIndex,anchor: .top)
                        }
                    }
                    
                }
            }
            .navigationTitle("Contacts")
            .offset { offsetRect in
                
                if offsetRect.minY != startOffset{
                    
                    startOffset = offsetRect.minY
                }
            }
            
        }
        .overlay(alignment: .trailing) {
            
            CustomScroller()
            
        }
        .onAppear{
            
         charactes = fetchCharactes()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                
                characterElevation()
                
            }
            
        }
        
    }
    func VerifyAndUpdated(index : Int,offset : CGFloat)->Bool{
        
        if charactes.indices.contains(index){
            
            charactes[index].pusOffset = offset
            charactes[index].isCurrent = false
            return true
        }
        return false
        
        
    }
    @ViewBuilder
    func CustomScroller ()->some View{
        
        GeometryReader{proxy in
            
            let rect = proxy.frame(in: .named("SCROLLER"))
            
            VStack(spacing: 0) {
                
                
                ForEach($charactes){$characte in
                    
                    
                    HStack(spacing: 15) {
                        
                        GeometryReader{inner in
                            
                            
                            let origin = inner.frame(in: .named("SCROLLER"))
                            
                            Text(characte.value)
                                .font(.callout.weight(characte.isCurrent ? .bold : .semibold))
                                .foregroundColor(characte.isCurrent ? .black : .gray)
                                .scaleEffect(characte.isCurrent ? 1.5 : 0.6)
                                .contentTransition(.interpolate)
                                .frame(width: origin.size.width,height: origin.size.height,alignment: .trailing)
                                .overlay {
                                    Rectangle()
                                        .fill(.red)
                                        .frame(width:15,height: 1)
                                        .offset(x:35)
                                }
                                .offset(x:characte.pusOffset)
                                .animation(.easeOut(duration: 0.3), value: characte.pusOffset)
                                .animation(.easeOut(duration: 0.3), value: characte.isCurrent)
                                .onAppear{
                                    
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                        
                                        
                                        characte.rect = origin
                                        
                                    }
                                }
                            
                            
                        }
                        .frame(width: 22)
                        
                        ZStack{
                            
                            if charactes.first?.id == characte.id{
                                
                                ScrollKnob(character: $characte, rect: rect)
                                
                            }
                         
                        }
                        .frame(width: 20,height: 20)
                    }
                }
                
            }
          
        }
        .frame(width: 55)
        .coordinateSpace(name: "SCROLLER")
        .padding(.vertical,15)
        .padding(.trailing,10)
        
        
        
    }
    @ViewBuilder
    func ScrollKnob(character : Binding<Character>,rect : CGRect)->some View{
        
        
        Circle()
            .fill(.black)
            .overlay {
                
                Circle()
                    .fill(.white)
                    .scaleEffect(isDragging ? 0.8 : 0.0001)
            }
        
            .scaleEffect(isDragging ? 1.3 : 1)
            .animation(.easeInOut(duration: 0.3), value: isDragging)
            .offset(y:offsetY)
            .gesture(
            
                DragGesture(minimumDistance: 5).updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    
                    isDrag = true
                    
                    var translation = value.location.y - 20
                    
                    translation = min(translation, (rect.maxY) - 20)
                    translation = max(translation, rect.minY)
                    
                    offsetY = translation
                    
                    characterElevation()
                    
                    
                })
                .onEnded({ value in
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        
                        isDrag = false
                        
                    }
                    if charactes.indices.contains(currentAcitiveIndex){
                        
                        withAnimation(.easeOut(duration: 0.3)){
                            
                            offsetY = charactes[currentAcitiveIndex].rect.minY
                        }
                    }
                    
                    
                    
                })
            
            )
        
        
    }
  
    func characterElevation(){
        
        
        if let index = charactes.firstIndex(where: { character in
            
            character.rect.contains(CGPoint(x: 0, y: offsetY))
        }){
        
            updateElevation(index: index)
            
        }
        
        
    }
  
    func updateElevation(index : Int){
        
        
        charactes[index].pusOffset = -35
        charactes[index].isCurrent = true
        
        var modifedIndiceis : [Int] = []
        
        currentAcitiveIndex = index
        
        modifedIndiceis.append(index)
        
        let otherOffsets : [CGFloat] = [-25,-36,-50]
        
        for _index in otherOffsets.indices{
            
            let newIndex = index + (_index + 1)
            
            let negativeIndex = index - (_index + 1)
            
            
            if VerifyAndUpdated(index: newIndex, offset: otherOffsets[_index]){
                
                modifedIndiceis.append(newIndex)
            }
            
            if VerifyAndUpdated(index: negativeIndex, offset: otherOffsets[_index]){
                
                modifedIndiceis.append(negativeIndex)
            }
            
        }
        
        
        for index_ in charactes.indices{
            
            
            if modifedIndiceis.contains(index_){
                
                charactes[index_].pusOffset = 0
                charactes[index_].isCurrent = false
            }
        }
        
        
    }
    @ViewBuilder
    func ContactView(character : Character)->some View{
        
        VStack(alignment:.leading,spacing: 10){
            
            Text(character.value)
                .font(.largeTitle.bold())
            
            ForEach(1...4 ,id:\.self){index in
                
                
                HStack(spacing:15){
                    
                    Circle()
                    .fill(character.color.gradient)
                     .frame(width: 50,height: 50)
                    
                    VStack(alignment:.leading,spacing: 10){
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color.gradient)
                            .frame(height: 30)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color.gradient)
                            .frame(height: 30)
                            .padding(.trailing,100)
                        
                        
                        
                    }

                    
                    
                    
                }
                
                
            }
            
        }
        .padding(15)
        .offset { offsetRect in
            
            
            let minY = offsetRect.minY
            let index = character.index
            
            if minY > 20 && minY < startOffset && !isDrag{
                
                updateElevation(index: index)
                
                withAnimation(.easeOut(duration: 0.15)){
                    
                    offsetY = charactes[index].rect.minY
                }
                
                
                
            }
        }
        
        
    }
    func fetchCharactes()->[Character]{
        
        let alphabets : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        var characters : [Character] = []
        
        
        characters = alphabets.compactMap({ character -> Character? in
            
            return Character(value: String(character))
        })
        
        let colors : [Color] = [.red,.yellow,.gray,.green,.orange,.purple,.indigo,.blue,.pink]
        
        for index in characters.indices{
            
            
            
            characters[index].index = index
            characters[index].color = colors.randomElement()!
        }
        return characters
        
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
